# Design Proposal: 4D Spatial-Temporal UI Architecture & GPGPU Trajectory Pipeline

**Status**: PROPOSED  
**Date**: 2026-06-16  
**Applicable Workspace**: `/Users/perkunas/digital-pipeline-repo`  
**Target Platform Runtimes**: React Web (WebGPU/WGSL) & Flutter Desktop (Impeller/Metal/Vulkan/Dart FFI)

---

## 1. Executive Summary & Design Goals

This proposal details the consolidated architecture for the **4D Spatial-Temporal (LUI) Viewer**. Safety-critical command and control systems (air traffic control, satellite operations, subsea logistics, and planetary rovers) require rendering thousands of moving objects across different physical media. Doing so at 60fps requires a design that handles:
* **Jitter-Free Precision**: Centimeter-level rendering precision across Earth, Moon, Mars, and orbital scales.
* **Temporal Coherence**: Jitter-free playback time synchronization ($t_{play}$) and out-of-order network telemetry packet processing.
* **Off-Thread & GPGPU Pipeline**: Decoupled trajectory propagation (SGP4/Splines) and collision/conjunction calculations executing directly in VRAM.
* **Platform Efficiency**: Zero-copy concurrency memory models (Transferable Buffers in React, Dart FFI native heaps in Flutter).
* **Automated Verification**: Headless CI/CD testing of coordinate engines, splines, and WGSL shader byte layouts.

---

## 2. 4D Coordinate Reference System (CRS) Translation Engine

### 2.1. Double-Single (DS) / Split-Precision Rendering (RTE)
To eliminate the CPU-GPU bandwidth bottleneck ($O(N)$ CPU calculations and heavy PCIe vertex uploads when the camera moves) and prevent 32-bit floating-point quantization (which causes visual stutter in $0.5$m increments):
1. **Coordinate Splitting**: On the CPU, when telemetry updates, each double-precision coordinate component ($X_{64}$) is split into two single-precision floats: `high` (MSB) and `low` (LSB):
   $$X_{high} = \text{float32}(X_{64})$$
   $$X_{low} = \text{float32}(X_{64} - X_{high})$$
2. **Static GPU Buffers**: Upload these `high` and `low` coordinates to the GPU storage buffers. They remain static in VRAM.
3. **Relative-to-Eye (RTE) Subtraction in Shader**: Pass the camera position split as `cam_high` and `cam_low` in a uniform buffer. The vertex shader performs subtraction using emulated double-precision arithmetic:
   ```wgsl
   struct DSFloat {
       high: f32,
       low: f32,
   }

   fn ds_sub(a: DSFloat, b: DSFloat) -> f32 {
       let t1 = a.high - b.high;
       let e = t1 - a.high;
       let t2 = ((-b.high - e) + (a.high - (t1 - e))) + a.low - b.low;
       return t1 + t2;
   }
   ```
   This prevents vertex jittering without requiring CPU-GPU transfers during camera pan or zoom.

### 2.2. Geoid Undulation Correction (Orthometric to Ellipsoidal Height)
To align aircraft pressure altitude (ADS-B) and marine MSL transponders with the ellipsoidal terrain model ($h_{ellipsoidal} = H_{MSL} + N$):
1. **Geoid Height Grid**: Cache a compressed $0.25^\circ \times 0.25^\circ$ coordinate grid of the **EGM96** or **EGM2008** model in memory.
2. **Bilinear Interpolation**: For each geodetic coordinate $(\phi, \lambda)$, look up and bilinearly interpolate to find the geoid undulation $N$, correcting the height before ECEF conversion.

### 2.3. Celestial Reference Frames (Moon & Mars)
* **Moon (PA to ME)**: Translate Principal Axis (PA) coordinates (used in orbital dynamics) to Mean Earth/Polar Axis (ME) coordinates (used for surface maps) using physical libration rotations:
  $$\mathbf{r}_{ME} = \mathbf{R}_{lib}(t) \mathbf{r}_{PA}$$
  Adjust for the $2\text{ km}$ lunar center-of-mass to center-of-figure offset.
* **Mars (Areoid)**: Implement the biaxial Martian ellipsoid ($f \approx 0.00589$) and correct surface elevations against the MOLA Areoid datum.

---

## 3. Temporal Context & Time-Echo Synchronization

### 3.1. Phase-Locked Loop (PLL) & Jitter Buffer
Directly coupling playback time $t_{play}$ to incoming network time $t_{stream}$ causes stutter due to network latency fluctuations.
1. **Dynamic Jitter Buffer**: Maintain a client-side playhead driven by `performance.now()`.
2. **Clock Rate Smoothing**: Target a smoothed delay offset:
   $$t_{target} = t_{stream\_max} - \Delta t_{buffer}$$
   A PID controller slightly adjusts the playback clock speed ($1.0 \pm 0.05$) to smoothly match $t_{target}$ without visual jumps.
3. **Boundary Reset Vector**: When transitioning states (e.g., Playback Mode $\to$ Live Mode), dispatch an `isTemporalBoundary = true` signal to flush velocity registers and prevent acceleration spikes in spline engines.

### 3.2. Out-of-Order Packet sliding-Window
1. **Sorted Queue**: Maintain a sorted, bounded queue of coordinates for each track based on timestamp.
2. **Late Segment Processing**: If a packet arrives out-of-order:
   - If $t_{packet} < t_{play} - t_{threshold}$, discard it as stale.
   - If $t_{packet} \ge t_{play} - t_{threshold}$, insert it in chronological order, mark the affected spline segment as "dirty," and trigger local interpolation recalculation.

### 3.3. Network-Level Echo Guard (Write Lock)
Relying on UI-level checks is fragile. The Echo Guard is enforced at the network API gateway:
* When the UI enters `PlaybackMode` or timeline scrubbing is active, a write lock is set on the API gateway client. All outgoing state updates are blocked at the socket level.

---

## 4. Off-Thread Kinematics & GPU Compute Pipelines

```mermaid
flowchart TD
    subgraph CPU Background Thread (Web Worker / Dart Isolate)
        A[Incoming Telemetry] --> B[Sliding-Window Sorted Queue]
        B -->|Broadphase Sweep-and-Prune| C[Active Collision Candidates]
    end

    subgraph GPU VRAM (WebGPU / Metal)
        D[TLE / Trajectory Double-Single Buffer] --> E[SGP4/Spline Compute Shader]
        E -->|Write Local coordinates| F[Vertex Buffer]
        C -->|Upload Candidate Pairs| G[Conjunction Compute Shader]
        G -->|Atomic Counter Append| H[Conjunction Append Buffer]
    end

    F -->|Zero-Copy Draw| I[3D Viewport]
    H -->|Asynchronous double-Buffered Readback| J[CPU Alarms Log]
    I -->|GPU Color Picking Offscreen| K[1x1 ID Texture]
    K -->|Async Readback| L[Mouse Hover Selection]
```

### 4.1. SGP4 & Trajectory Computation Split
WGSL does not support native double-precision floats (`f64`). 
1. **High-Precision Keyframes**: Run SGP4 propagation and kinematic calculations in WASM/C++ on background threads (Web Workers / Dart Isolates) in double precision.
2. **GPU Spline Interpolation**: Upload double-single keyframes to the GPU. The compute shader performs linear/cubic Hermite interpolation between keyframes on the GPU to generate high-density vertex paths at 60fps.

### 4.2. Conjunction Append Buffer & Spatial Hashing
To avoid $O(N^2)$ brute-force calculations and massive $N \times N$ matrix memory allocations:
1. **Append Buffer**: Replace the $N \times N$ matrix with a flat **Append Buffer** using atomic counters:
   ```wgsl
   struct ConjunctionPair {
       object_a: u32,
       object_b: u32,
       distance: f32,
   }
   struct ConjunctionOutput {
       counter: atomic<u32>,
       pairs: array<ConjunctionPair, 1024>,
   }
   ```
2. **Spatial Partitioning (Broadphase/Narrowphase Split)**:
   - Run a fast Axis-Aligned Bounding Box (AABB) Sweep-and-Prune on the CPU.
   - Upload the resulting list of candidate pairs to the GPU.
   - The GPU compute shader executes the narrow-phase exact distance calculation exclusively on these candidate pairs.

---

## 5. Viewport Interaction & Render Optimizations

### 5.1. GPU ID Picking (Color Picking)
To prevent stalling the GPU pipeline with coordinate readbacks for mouse selection:
1. **Offscreen Framebuffer Pass**: Render interactive 3D nodes to an offscreen, 1x1 or mouse-centered texture.
2. **Integer IDs**: The fragment shader writes the unique 32-bit unsigned integer ID of each node to the texture (`r32uint` format).
3. **Async Readback**: Read back the single pixel under the cursor asynchronously (`mapAsync`), achieving selection lookup in $O(1)$ without CPU-side spatial indexing.

### 5.2. Reversed-Z Depth Buffer
To eliminate Z-fighting when zooming from planetary scale down to sub-meter elements:
* Map the depth buffer from $z=1.0$ (near plane) to $z=0.0$ (far plane) and utilize a 32-bit floating-point depth buffer (`depth32float`).

### 5.3. GPU-Generated Link Geometry & MSDF Text
* **Visibility & LOS Checks**: Perform ray-ellipsoid line-of-sight checks in a compute shader. Write coordinates of visible links directly to an **Indirect Draw Buffer** (`drawIndirect`), bypassing the CPU.
* **Text Rendering**: Render overlay text directly in the 3D coordinate space using Multi-channel Signed Distance Fields (MSDF) text shaders, keeping labels entirely in VRAM.

---

## 6. Concurrency & Memory Models

### 6.1. React: Double-Buffered Transferable ArrayBuffers
If `SharedArrayBuffer` is disabled by the hosting server (missing COOP/COEP headers):
* Implement a double-buffered queue. The worker writes to `Buffer_A`, transfers it to the UI thread using the transfer list (`postMessage(payload, [Buffer_A])`), and writes to `Buffer_B` in the next frame. This avoids data cloning overhead.

### 6.2. Flutter: Dart FFI Native Heap sharing
Dart Isolates copy objects via ports, creating significant GC overhead for large coordinate arrays.
* Allocate coordinate buffers on the native C-heap using `dart:ffi`. Pass the raw memory pointers (`Pointer<Double>`) between the background Isolate and the UI thread, bypassing Dart heap boundaries.

---

## 7. Verification & CI/CD Testing Matrix

To guarantee mathematical correctness and performance stability:

1. **Precision & geoid Tests**:
   - Assert geodetic-to-ECEF translations match mathematical tolerances ($10^{-5}\text{ m}$).
   - Test geoid undulation lookups: verify MSL altitude inputs are corrected against EGM96 grids (e.g. verify MSL altitude of 10m at coordinate $(0,80)$ evaluates to ellipsoidal height of $-55$m).
2. **Spline & Trajectory Tests**:
   - Stress-test Hermite splines with simulated telemetry packets containing random arrival jitters. Assert that the spline does not overshoot beyond the bounding box of the keyframe boundaries.
   - Verify SGP4 propagation limits: raise warnings when TLE age exceeds 7 days.
3. **Headless Shader Testing**:
   - Run Node.js with SwiftShader/WebGPU mocks in CI/CD to validate WGSL compilation and struct memory alignments (checking 16-byte boundary rules).
4. **Temporal Context Tests**:
   - Mock the network API router and assert that moving the timeline scrubber in Playback Mode dispatches zero mutations to the outgoing WebSocket/gRPC gateways.

---
