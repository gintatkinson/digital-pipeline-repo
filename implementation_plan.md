# Implementation Plan: Full Decontamination of Audited Items

This plan addresses every file and category listed in the audit report [`docs/audits/domain-pollution-audit.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/audits/domain-pollution-audit.md) to complete the decontamination of geodetic coordinates, hardware references, and telecom-specific domain pollution.

---

## 1. Sequence Matrix: Who, What, When, and Which Skill

To prevent context bloat and ensure layered boundary isolation, work is divided between the Coordinator and Worker Subagents according to the following sequence:

| Sequence / Phase | Who | What (Actions & Deliverables) | Which Skill |
| :--- | :--- | :--- | :--- |
| **Phase 1: Pre-emptive Audit** | **Worker Subagent** (`Role: adversarial-code-auditor`) | Performs code and test integrity audits on the target files; formats and files bugs as GitHub issues via `gh issue create`. | **`adversarial-code-auditor`** |
| **Phase 1: Pre-emptive Audit** | **Coordinator** | Spawns the audit subagent; collects the registered issue URLs. | *Coordination & Dispatch* |
| **Phase 2: Bug Fix Loop** | **Worker Subagents** (`Role: debug-protocol-worker`) | Runs the 8-step bug-hunting loop for each issue: reproduces bugs, writes repro tests, applies codebase edits to decontaminate source files/JSON, and comments/closes the issues. | **`debug-protocol`** |
| **Phase 2: Bug Fix Loop** | **Coordinator** | Loops through the unresolved bug issues; dispatches a fresh subagent for each bug; runs full verification builds (`flutter analyze`/`flutter test`); commits code; terminates subagents. | *Coordination & Dispatch* |
| **Phase 3: Spec Compliance Audit** | **Worker Subagent** (`Role: spec-implementation-auditor`) | Audits the final codebase against target functional specifications to ensure no gaps or drifts exist. | **`spec-implementation-auditor`** |
| **Phase 3: Spec Compliance Audit** | **Coordinator** | Spawns the auditor subagent; reviews the audit report; runs backlog reconciliation (`reconcile_backlog.py`); pushes to remote branch. | *Coordination & Dispatch* |

---

## 2. Specifications & Documentation (Verified or Completed)

The following files were audited for containing geodetic coordinates or references to `ietf-geo-location`. They have already been decontaminated in the git history (e.g. commit `37136f4`), but we will run a final automated verification on them:

*   [`implementation_plan.md`](file:///Users/perkunas/jail/digital-pipeline-repo/implementation_plan.md)
*   [`docs/features/feat-002-alternate-systems.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/features/feat-002-alternate-systems.md)
*   [`docs/features/feat-12-yang-compiler.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/features/feat-12-yang-compiler.md)
*   [`docs/feat-hardware-decoupled-persistence-design.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/feat-hardware-decoupled-persistence-design.md)
*   [`docs/features/feat-44-downstream-baseline.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/features/feat-44-downstream-baseline.md)
*   [`docs/designs/feat-65-solution.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-65-solution.md)
*   [`docs/designs/persistence-architecture-blueprint.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/persistence-architecture-blueprint.md)
*   [`docs/decisions/adversarial_audit_synthesis.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/adversarial_audit_synthesis.md)
*   [`docs/decisions/incident_retrospective.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/incident_retrospective.md)
*   [`docs/designs/feat-44-solution.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-44-solution.md)
*   [`docs/decisions/audits/pipeline_integration_critique.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/audits/pipeline_integration_critique.md)
*   [`docs/designs/feat-backprop-flutter-source-changes.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-backprop-flutter-source-changes.md)
*   [`docs/designs/feat-epic-template-mandate-plan.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-epic-template-mandate-plan.md)
*   [`docs/requirements/dynamic-geolocation-motion-blueprint.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/requirements/dynamic-geolocation-motion-blueprint.md)
*   [`docs/decisions/uml_frontend_alignment_audit.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/uml_frontend_alignment_audit.md)
*   [`docs/decisions/upstream_decontamination_baseline_report.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/upstream_decontamination_baseline_report.md)
*   [`docs/use-cases/uc-02-local-firebase-emulator.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/use-cases/uc-02-local-firebase-emulator.md)
*   [`docs/designs/feat-g1-g12-solution-definition.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-g1-g12-solution-definition.md) (Deleted in cleanup)
*   [`docs/decisions/audits/astrodynamics_geodesy_critique.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/audits/astrodynamics_geodesy_critique.md) (Deleted in cleanup)
*   [`docs/decisions/audits/communications_rf_laser_critique.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/audits/communications_rf_laser_critique.md) (Deleted in cleanup)

---

## 3. React UI Codebase (Verified or Completed)

The following files have been decontaminated to remove references to `latitude`, `longitude`, `ReferenceFrame`, and `contained-chassis` structures:

*   [`web_react/src/components/property-grid.tsx`](file:///Users/perkunas/jail/digital-pipeline-repo/web_react/src/components/property-grid.tsx)
*   [`web_react/src/types.ts`](file:///Users/perkunas/jail/digital-pipeline-repo/web_react/src/types.ts)

---

## 4. SQLite Database & Seed Data Assets (IN PROGRESS)

### 4.1. [ntt_exchanges_japan_763.json](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/ntt_exchanges_japan_763.json)
- **Problem**: Contains key names `"latitude"` and `"longitude"`.
- **Action**: Replace `"latitude"` $\rightarrow$ `"dim_0"` and `"longitude"` $\rightarrow$ `"dim_1"` across all 763 entries, and wrap them under a generic `"position"` parent key.

### 4.2. [cable_landing_stations_japan.json](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/cable_landing_stations_japan.json)
- **Problem**: Contains key names `"latitude"` and `"longitude"`.
- **Action**: Replace `"latitude"` $\rightarrow$ `"dim_0"` and `"longitude"` $\rightarrow$ `"dim_1"`, wrapped under a generic `"position"` key.

### 4.3. [domain_seed_strategy.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/data/seeds/domain_seed_strategy.dart)
- **Problem**: References `"latitude"`, `"longitude"`, and `"location/ellipsoid"` when reading JSON files and building SQLite batches.
- **Action**: Refactor the parsing loop to extract `item['position']['dim_0']` and `item['position']['dim_1']`. Change properties map output to `"position": {"dim_0": lat, "dim_1": lon, "dim_2": height}`.

---

## 5. Flutter Map Viewport & Camera Engine (TODO)

### 5.1. [virtual_camera.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/virtual_camera.dart)
- **Problem**: Defines variables `latitude`, `longitude`, and `altitude`.
- **Action**: Rename fields and parameters:
  - `latitude` $\rightarrow$ `dim_0`
  - `longitude` $\rightarrow$ `dim_1`
  - `altitude` $\rightarrow$ `dim_2`
  - Refactor static validation range checks (e.g. `dim_0` clamped to `[-90, 90]` and `dim_1` to `[-180, 180]`).

### 5.2. [camera_controller.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/camera_controller.dart)
- **Problem**: Calls `camera.latitude`, `camera.longitude`, and `camera.altitude` to adjust drag, pan, zoom, and camera interpolation flights.
- **Action**: Rename all references to use `camera.dim_0`, `camera.dim_1`, and `camera.dim_2`.

### 5.3. [cesium_3d_native.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/cesium_3d_native.dart)
- **Problem**: Maps native parameters using `latitude` and `longitude`.
- **Action**: Map to `dim_0` and `dim_1`.

### 5.4. [cesium_engine.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/cesium_engine.dart)
- **Problem**: Writes coordinates to native reference fields: `native.ref.latitude`, `native.ref.longitude`.
- **Action**: Refactor to `native.ref.dim_0`, `native.ref.dim_1`.

### 5.5. [globe_tile_renderer.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/globe_tile_renderer.dart)
- **Problem**: Coordinate mapping logic uses `camera.latitude`/`longitude`.
- **Action**: Map using `camera.dim_0`/`dim_1`.

### 5.6. [bridge_bindings.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/map_viewport/cesium_3d/native/bridge_bindings.dart)
- **Problem**: Struct has fields `latitude`, `longitude`, `altitude`.
- **Action**: Rename properties to `dim_0`, `dim_1`, `dim_2`.

---

## 6. Viewport UI & Layout Components (TODO)

### 6.1. [topographical_view.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/topographical_view.dart)
- **Problem**: Local variables `latitude` and `longitude` are tracked in the view state.
- **Action**: Rename state trackers to `dim_0` and `dim_1`.

### 6.2. [scene_3d_viewport.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport.dart)
- **Problem**: Text indicators show `Latitude: ...` and `Longitude: ...` using geodetic terminology.
- **Action**: Rename text labels to generic descriptors `Dim_0` and `Dim_1`.

### 6.3. [scene_3d_viewport_classes.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport_classes.dart)
- **Problem**: Mathematical constants like `wgs84EquatorialRadius` and methods like `projectWgs84ToScreen` are coupled to geodetic Earth model attributes.
- **Action**: Refactor geodetic terminology and labels to generic ellipsoidal geometry matrix functions.

---

## 7. Unit & Integration Test Suites (TODO)

The following test suites assert coordinate values. We will perform search-and-replace transformations on each of these to replace `latitude`, `longitude`, `altitude` assertions with `dim_0`, `dim_1`, `dim_2`:

*   [`app_flutter/integration_test/camera_gestures_navigation_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/camera_gestures_navigation_test.dart)
*   [`app_flutter/integration_test/globe_camera_drag_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/globe_camera_drag_test.dart)
*   [`app_flutter/integration_test/globe_camera_reset_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/globe_camera_reset_test.dart)
*   [`app_flutter/integration_test/visual_rendering_defect_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/visual_rendering_defect_test.dart)
*   [`app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/adversarial_fuzzer_test.dart)
*   [`app_flutter/test/cesium_3d/camera_collision_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/camera_collision_test.dart)
*   [`app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/camera_controller_angle_wrapping_test.dart)
*   [`app_flutter/test/cesium_3d/camera_controller_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/camera_controller_test.dart)
*   [`app_flutter/test/cesium_3d/camera_drag_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/camera_drag_test.dart)
*   [`app_flutter/test/cesium_3d/collapse_hud_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/collapse_hud_test.dart)
*   [`app_flutter/test/cesium_3d/ctrl_drag_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/ctrl_drag_test.dart)
*   [`app_flutter/test/cesium_3d/double_click_fly_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/double_click_fly_test.dart)
*   [`app_flutter/test/cesium_3d/globe_focus_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/globe_focus_test.dart)
*   [`app_flutter/test/cesium_3d/globe_tile_renderer_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/globe_tile_renderer_test.dart)
*   [`app_flutter/test/cesium_3d/hud_update_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/hud_update_test.dart)
*   [`app_flutter/test/cesium_3d/right_click_drag_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/right_click_drag_test.dart)
*   [`app_flutter/test/cesium_3d/scroll_zoom_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/scroll_zoom_test.dart)
*   [`app_flutter/test/cesium_3d/shift_drag_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/shift_drag_test.dart)
*   [`app_flutter/test/cesium_3d/tile_imagery_repaint_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/tile_imagery_repaint_test.dart)
*   [`app_flutter/test/cesium_3d/virtual_camera_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/virtual_camera_test.dart)
*   [`app_flutter/test/cesium_3d_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d_test.dart)
*   [`app_flutter/test/domain/cesium_3d/viewport_math_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/cesium_3d/viewport_math_test.dart)
*   [`app_flutter/test/features/topology/globe_rendering_benchmark_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/features/topology/globe_rendering_benchmark_test.dart)
*   [`app_flutter/test/topology/camera_reset_reproduction_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/camera_reset_reproduction_test.dart)
*   [`app_flutter/test/topology/double_click_fly_acceptance_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/double_click_fly_acceptance_test.dart)
*   [`app_flutter/test/topology/scene_3d_viewport_golden_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/scene_3d_viewport_golden_test.dart)
*   [`app_flutter/test/topology/scene_3d_viewport_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/scene_3d_viewport_test.dart)
*   [`app_flutter/test/topology/scene_3d_viewport_widget_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/scene_3d_viewport_widget_test.dart)
*   [`app_flutter/test/topology/scroll_zoom_test.dart`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/topology/scroll_zoom_test.dart)

---

## 8. Verification & Database Rebuild

Once the source code edits are complete:
1.  **Regenerate Database**: Run the seeder logic to rebuild [`properties_db.db`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/properties_db.db) and compress it to [`properties_db.db.gz`](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/properties_db.db.gz):
    ```bash
    dart app_flutter/lib/data/database_initializer.dart
    ```
2.  **Verify compilation & analysis**:
    ```bash
    flutter analyze
    ```
3.  **Run full test suites**:
    ```bash
    flutter test
    ```

---

## 9. Immediate Action: Bug Fix Loop for Issue #258

Dispatch subagents to execute `debug-protocol` on GitHub Issue #258 (Decontaminate geodetic coordinates in Flutter Map Viewport & Camera Engine).
This includes executing the 8-step protocol: reproduction, hypothesis, investigation, evidence gathering, root cause analysis, fix implementation, and verification for the files listed in Section 5.
