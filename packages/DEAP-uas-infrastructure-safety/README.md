# DEAP Low-Altitude UAS & Infrastructure Safety Platform

> **Package Identifier:** `deap-uas-infrastructure-safety`  
> **Status:** `PRODUCTION-GRADE`  
> **Classification:** `Low-Altitude UAS Infrastructure Inspection & Safety Platform`  
> **Target Regulatory & Engineering Frameworks:**  
> `JARUS SORA v2.5 (SAIL I-VI)` | `ASTM F3269-17 RTA Geofencing` | `ASTM F3411-22a Remote ID` | `RTCA DO-365B DAA` | `ROS2 Humble/Jazzy` | `PX4 Autopilot`

---

## Executive Overview

The **DEAP Low-Altitude UAS & Infrastructure Safety Platform** provides a comprehensive, automated safety-engineering framework for autonomous Beyond Visual Line of Sight (BVLOS) Unmanned Aircraft System (UAS) operations. Designed specifically for critical infrastructure inspection—including cellular towers, high-voltage electrical grids, and cross-country energy pipelines—this package integrates regulatory compliance, formal safety analysis, and real-time execution safety directly into software development pipelines.

By combining top-down **System-Theoretic Process Analysis (STPA)** and bottom-up **Failure Mode, Effects, and Criticality Analysis (FMECA)** with automated AST verification and runtime monitors, the platform ensures safety constraints derived from international civil aviation standards are strictly satisfied across ROS2 node implementations and PX4 flight controller modules.

---

## Regulatory Compliance & Safety Specifications

### 1. JARUS SORA v2.5 (Specific Operations Risk Assessment)
- **Risk Characterization:** Computes Intrinsic Ground Risk Class (GRC 1–7) based on kinetic energy and population density, and Intrinsic Air Risk Class (ARC-a to ARC-d) based on airspace density.
- **SAIL Qualification:** Maps operational risk profiles to Specific Assurance and Integrity Levels (**SAIL I through SAIL VI**).
- **Operational Safety Objectives (OSOs):** Enforces OSO compliance across software integrity, containment, and tactical mitigation performance standards (TMPSR).
- **Safety Traceability:** All specification elements and codebase artifacts maintain 100% bi-directional traceability using `/// Safety-Realises:` tags linking SORA GRC/ARC metrics to code implementation.

### 2. ASTM F3269-17 Run-Time Assurance (RTA) & Geofencing
- **Architectural Pattern:** Implements the Simplex Architecture pattern separating Untrusted Complex Logic (UCL) from a Verified Safety Filter (VSF).
- **Containment Bounds:** Enforces hard 3D spatial containment geofence buffers (hard boundary, soft warning boundary) with deterministic return-to-launch (RTL) or loiter fallbacks.
- **Runtime Monitoring:** Real-time checking of position vectors against polygon boundaries with zero dynamic memory allocation during spatial evaluation loops.

### 3. ASTM F3411-22a Broadcast & Network Remote ID
- **Direct Remote ID (Broadcast):** Generates and transmits 1 Hz Open-Drone-ID (ODID) broadcast payloads over Bluetooth LE (4.x / 5.x) and Wi-Fi Neighbor Awareness Networking (NAN).
- **Network Remote ID:** Formats telemetry payloads (UAS ID, location, altitude, velocity, timestamp, operator location) for cellular UTM / USSP integration via 3GPP TS 22.125 / TS 23.256 enablers.
- **Message Integrity & Validation:** Static payload validation gates enforce message structure, timestamp freshness (`Δt < 1.0s`), and GPS location accuracy bounds.

### 4. RTCA DO-365B Detect and Avoid (DAA)
- **Sensory Processing:** Ingests cooperative (ADS-B In, Remote ID) and non-cooperative (LiDAR, Radar, Electro-Optical) intruder tracks.
- **Well-Clear Volume:** Maintains minimum DAA well-clear distances (horizontal distance $D_{mod}$, vertical distance $H^*$ and time-to-co-altitude $\tau_{mod}$).
- **Alerting & Guidance:** Provides deterministic 3-tier threat alerts (Traffic Advisory, Preventive Advisory, Corrective Resolution Advisory) and auto-maneuver commands to maintain operational well-clear boundaries.

---

## Flight Software Build Rules & Middleware Architecture

### 1. ROS2 Build Rules & Middleware QoS Profiles
- **Target Distribution:** ROS2 Humble Hawksbill / Jazzy Jalisco C++ (`rclcpp::Node`).
- **Memory Allocation:** Zero dynamic heap allocation in execution critical loops; uses `tlsf` (Two-Level Segregated Fit) or stack allocation.
- **QoS Profile Enforcements:**
  - **Telemetry / Flight Controls:** Reliable reliability, Transient Local durability, System Defaults liveliness.
  - **Sensor Data (LiDAR/Radar/Imager):** Best Effort reliability, Volatile durability, Keep Last history with depth 1–5.
  - **Heartbeats & Fail-Safe Signals:** Reliable reliability, Keep Last history (depth 1), deadline enforcement (`< 100ms`).
- **Launch Safety Monitors:** Node launch files incorporate automated life-cycle verification monitors checking QoS compatibility prior to transition to active state.

### 2. PX4 Autopilot Module Architecture
- **Module Architecture:** Integrates with PX4 Autopilot using `ModuleBase` lifecycle pattern with zero-blocking main loop constraints.
- **uORB Topic Messaging:** Standardized uORB messaging for sensor data, vehicle command (`vehicle_command`), vehicle status (`vehicle_status`), and fail-safe flags (`vehicle_failsafe_flags`).
- **Safe State Fail-Safe Behaviors:**
  - **Lost C2 Datalink (`t_loss > 2.0s`):** Automatic loiter transition followed by deterministic Return-To-Launch (RTL).
  - **Geofence Breach:** Immediate activation of RTA VSF controller overriding manual/auto commands to execute RTL or safe emergency land.
  - **Low Battery Cell Sag:** Multi-stage thresholding (Warning -> RTL -> Emergency Immediate Land).
  - **EMF / Magnetometer Saturation:** Automatic fall-back to dual-optical flow / visual-inertial odometry state estimation.

---

## Directory Structure

```
packages/DEAP-uas-infrastructure-safety/
├── README.md
├── pyproject.toml
├── .agents/
│   └── AGENTS.md
├── .pipeline/
│   ├── constitution.md
│   └── profiles/
│       ├── ros2_cpp.md
│       └── px4_module.md
└── docs/
    └── architecture/
        ├── DEAP_UAS_INFRASTRUCTURE_SAFETY_CONCEPT_PAPER.md
        └── DEAP_SYSML_V2_SAFETY_MODEL_SPECIFICATION.sysml
```

---

## License & Governance

This package is governed by the **DEAP Tier 1 UAS Infrastructure Safety Constitution** (`.pipeline/constitution.md`) and project-scoped subagent rules (`.agents/AGENTS.md`). All modifications must be verified through automated static analysis, compile gates, and SORA assurance checks.
