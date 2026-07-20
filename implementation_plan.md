# Implementation Plan: 3D Globe Visual/Rendering Fixes & Parity Resolver

This plan details the codebase modifications to resolve the five visual, rendering, gesture, and category alignment defects identified across the Flutter and React codebases.

---

## 1. Viewport Offset/Shift Bug (Issue 4)

* **Defect**: Camera projections shift or offset during click-to-camera or view transitions due to hardcoded minimum projection clamp values (`10000.0` instead of `1.0`) and non-synchronized camera rotation parameters inside `_clickToCamera`.
* **Target File**: `app_flutter/lib/features/topology/scene_3d_viewport.dart`
* **Changes**:
  1. In `project` method: update `safeDepth` projection clamp check from `10000.0` to `1.0`.
  2. In `_getHorizonPath` and `project` methods: dynamically adjust camera altitude (`cRad`) to `Ellipsoid.wgs84EquatorialRadius + camera.altitude` when it is less than `Ellipsoid.wgs84EquatorialRadius`.
  3. In `_clickToCamera` method: synchronize camera rotation parameters by passing `baseRotation` and `baseTilt` (instead of `0.0`, `0.0`) to `painter.project`.

---

## 2. LOD Seams (Problem 5)

* **Defect**: Tile boundaries show straight rectangular seam lines instead of warping along the globe, caused by missing vertex culled/behind checks.
* **Target File**: `app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart`
* **Changes**:
  1. Inside the main `renderTiles` triangle generation loop, add `anyBehind` checks (matching `calculateIndicesForTesting`) to discard triangles that cross behind the visible horizon or have vertices too far behind the camera.

---

## 3. Label Collision (Problem 6)

* **Defect**: Node label texts overlap and collide, reducing readability in dense topology views.
* **Target Files**:
  * `app_flutter/lib/features/topology/topology_map.dart` (Flutter)
  * `web_react/src/components/topology-map.tsx` (React)
* **Changes**:
  1. **Flutter**: Introduce a local `drawnLabelRects` bounding box cache inside `TopologyPainter.paint`. For each node label, calculate the text bounding box, check if it overlaps existing labels by more than 10%, and skip painting if it collides.
  2. **React**: Replicate the exact same label collision resolver logic inside the canvas node drawing loop in `topology-map.tsx` using `ctx.measureText` for label dimensions.

---

## 4. Flat Globe Shading & Atmosphere (Problems 7 & 8)

* **Defect**: Visual depth is lost on satellite tiles making the globe appear flat, and the atmosphere lacks volumetric depth.
* **Target File**: `app_flutter/lib/features/topology/scene_3d_viewport.dart`
* **Changes**:
  1. In `paint` method: dynamically adjust `cRad` if it is less than the equatorial radius.
  2. In `paint` method: implement a translucent shading overlay Paint layer using a `RadialGradient` drawn on top of the rendered tiles to restore 3D volumetric shading.

---

## 5. Misaligned Grid Categories (Problem 15)

* **Defect**: False-positive structural category dimming highlights structural categories when metrics or unrelated views are active.
* **Target File**: `web_react/src/components/property-grid.tsx`
* **Changes**:
  1. Adjust `isHighlighted` in `property-grid.tsx` to precisely check for active views:
     - Highlight `Geodetic Coordinate Frame` only when `activeView === 'Location' || activeView === 'Ingestion'`.
     - Highlight `Alternate Structural Grid Frame` when `activeView === 'Chassis'` or default `activeView === 'root'`.
     - Dim all other categories when unrelated views (e.g. `Metrics`) are active.

---

## 2. Verification Steps

### Step 1: React Tests validation
* Run `npm test` inside `web_react` to verify all tests pass:
  ```bash
  npm test
  ```

### Step 2: Flutter Tests validation
* Run `flutter test` inside `app_flutter` to verify all tests pass:
  ```bash
  flutter test
  ```

---

## 6. Scene 3D Viewport Architectural Refactoring

* **Defect**: The `scene_3d_viewport.dart` file suffers from severe Garbage Collection (GC) jank, duplicated math logic, and God Class anti-patterns.
* **Target File**: `app_flutter/lib/features/topology/scene_3d_viewport.dart`
* **Changes**:
  1. **Phase 1: Math & Domain Extraction**: 
     - Add `VirtualCameraNormalization` extension.
     - Extract `ElevationProvider` service.
     - Create `CoordinateTransformer` engine to handle 3D-to-2D projection and horizon generation.
  2. **Phase 2: State Normalization**:
     - Create `SceneViewState` as a `ChangeNotifier` to hold all pre-calculated rendering data.
     - Eliminate string allocations in caches by using Dart 3 Records for cache keys (`ElevationCacheKey`).
  3. **Phase 3: Painter Decomposition**:
     - Create `SceneLayer` base interface.
     - Implement `BackgroundLayer`, `GlobeLayer`, `TopologyLayer`, and `HUDLayer`.
     - Simplify `Scene3DViewportPainter` to simply iterate through and paint the injected layers.
  4. **Phase 4: UI Component Cleanup**:
     - Extract `CameraStatsPanel` and `MapConfigPanel` from the massive `Scene3DViewportState.build()` method into standalone stateless widgets.
     - Clean up the main stack to only compose these widgets.

* **Verification**:
  - Run `flutter test` inside `app_flutter` to verify no regressions in rendering math.
  - Run `flutter analyze` to ensure structural validity of the extracted widgets and layers.

---

## 7. Automated Performance Profiling Test Suite

* **Defect**: No automated regression test suite exists to capture 3D rendering engine performance issues or catch frame drop regressions below 60 FPS.
* **Target Files**:
  * `app_flutter/pubspec.yaml`
  * `app_flutter/test_driver/integration_test.dart`
  * `app_flutter/integration_test/viewport_perf_test.dart`
* **Changes**:
  1. **Phase 1: Integration Test Setup**: Configure `integration_test` in `pubspec.yaml`, create `test_driver/integration_test.dart`, and create `integration_test/viewport_perf_test.dart`.
  2. **Phase 2: Live Persistence Test Fixture**: Seed 500 ground nodes, 100 space nodes, and 200 network links directly into the live SQLite database (Zero-Mocking Live Persistence Mandate). Mount the full application against this DB. Clean up during teardown.
  3. **Phase 3: Interaction & Recording Script**: Use `WidgetTester.traceAction()` to record aggressive viewport usage (scrolling, panning, UI toggling, iterating nodes to trigger fly-to animations, properties pane edits, and density table tabs).
  4. **Phase 4: Regression Thresholds & Output**: Save the TimelineSummary via `writeTimelineToFile`. Implement `expect()` assertions that enforce >60 FPS performance (average frame build < 16.0ms, 90th percentile build < 16.6ms, average rasterizer < 16.0ms).

* **Verification**:
  - Run the profiling test using the Flutter CLI command for macOS/simulator.
  - Verify that the assertions pass and timeline output is saved.

---

## 8. Agent Skill: Performance Profiling Test Automation

* **Defect**: Lack of documented guidelines and automated agent workflows to generate and maintain performance profiling tests.
* **Target File**: `.agents/skills/performance-profiling-test-automation/SKILL.md`
* **Changes**:
  1. Create a new skill documentation file covering the purpose of automated 3D viewport profiling.
  2. Detail setup standards for configuring `integration_test` and `test_driver`.
  3. Explicitly document Zero-Mocking Persistence (Section 1.9 compliance) with instructions for seeding live local databases.
  4. Detail Interactive Animation Tracing techniques with `WidgetTester.traceAction()`.
  5. Include strict Frame Budget Assertions limits (Average build < 16.0ms, 90th percentile build < 16.6ms, Average rasterizer < 16.0ms).
  6. Provide execution commands for macOS and simulator targets.

---

## 9. Automated Release Compilation and Zip Packaging

* **Defect**: The automated verification script does not produce a release build artifact.
* **Target File**: `scripts/verify_downstream_baseline.py`
* **Changes**:
  1. Modify `scripts/verify_downstream_baseline.py` inside the Flutter verification block.
  2. Add `subprocess.run(["flutter", "build", "macos", "--release"], cwd=dest, check=True)` after tests.
  3. Add `subprocess.run(["zip", "-r", "../../app_flutter_release.zip", "Platform Console.app"], cwd=os.path.join(dest, "build", "macos", "Build", "Products", "Release"), check=True)` to package the app into the root of the repository.
