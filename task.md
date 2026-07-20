# Task Checklist: Visual & Rendering Defects Resolution

- [x] Fix Viewport Offset/Shift Bug (Issue 4) in `scene_3d_viewport.dart`
- [x] Fix LOD Seams (Problem 5) in `globe_tile_renderer.dart`
- [x] Fix Label Collision (Problem 6) in both `topology_map.dart` and `topology-map.tsx`
- [x] Fix Flat Globe Shading & Atmosphere (Problems 7 & 8) in `scene_3d_viewport.dart`
- [x] Fix Misaligned Grid Categories (Problem 15) in `property-grid.tsx`
- [x] Run test suite (`flutter test` and React tests) to verify correctness
- [x] Perform backlog reconciliation using `reconcile_backlog.py`
- [x] Generate walkthrough and report results

# Viewport Refactoring

- [x] Refactor `scene_3d_viewport.dart` according to architect specifications
- [x] Run test suite to verify no regressions

# Performance Profiling Integration Test Suite & Agent Skill

- [x] Implement performance profiling integration test suite with visual screenshot captures (`viewport_perf_test.dart`)
- [x] Run test suite via `flutter drive` to verify performance thresholds and capture screenshots
- [x] Package the `performance-profiling-test-automation` skill at `.agents/skills/`

# Automated Packaging Pipeline

- [x] Integrate release compilation and zip packaging into `verify_downstream_baseline.py`
- [x] Execute build run to compile the executable and generate `app_flutter_release.zip`

# NTT Exchanges, Landing Stations & App Defects Remediation

- [x] Seed 763 NTT exchanges, cable landing stations, space nodes, and links in `database_initializer.dart` matching the data source format
- [x] Fix double Earth-radius coordinate projection calculations in `scene_3d_viewport.dart` and `scene_3d_viewport_classes.dart`
- [x] Enforce database overwrite in `repository_resolver.dart` to prevent database path drift
- [x] Enable macOS outbound network entitlements for basemap tile fetching
- [x] Resolve stuck table spinner bug in `tables_view_model.dart` (by debouncing stream events to prevent infinite abort loops)
- [x] Verify link projection and rendering on the 3D viewport
- [x] Add mechanical node and link assertions in the performance test suite to prevent false passes
- [x] Run baseline verification and visual performance profiling tests

# Workspace Contamination Audit

- [x] Scan workspace codebase for cross-talk references to other projects (e.g. `3dgs-phoenix`, `3dgs-ion`) and clean them up
