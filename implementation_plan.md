# Handoff Implementation Plan: Recursive Debugging Protocol

This plan executes the systematic verification and resolution of Defects A, B, C, and D (Issues #41, #40, #39, #38) using the **`debug-protocol`** 8-step recursive bug loop.

## 1. Goal Description
1. Create the new visual/gestural integration test `app_flutter/integration_test/camera_gestures_navigation_test.dart` containing exhaustive tests for camera flight, panning, HUD updating, and rotation.
2. Run BOTH `camera_gestures_navigation_test.dart` (visual/gestural) and `node_iteration_test.dart` (performance profiling/leak detection) on the current `main` branch to verify they **fail** (RED phase).
3. Merge `origin/feat/backprop-flutter-source-changes` containing the fixes.
4. Run BOTH tests again on the merged codebase to verify they **pass** (GREEN phase).
5. Audit and present the visual screenshots and performance regression logs (`benchmark_results.jsonl`).
6. Push changes to `origin/main` and reconcile the backlog.

---

## 2. Defects Addressed

### A. Viewport Paint Overdraw/Bleeding (Issue #41)
* **Problem**: In scene_3d_viewport.dart, custom painter elements bleed outside the viewport boundaries during resize/zoom reflows.
* **Fix**: Apply a strict clip rect to constrain painting within the layout dimensions.
* **Target File**: `app_flutter/lib/features/topology/scene_3d_viewport.dart`

### B. Flat Seams Patchwork & Color Discontinuity (Issue #40)
* **Problem**: Low mesh subdivision logic in globe_tile_renderer.dart renders flat edges on tile seams and creates sharp color mismatches.
* **Fix**: Increase boundary grid subdivisions to 16 and smooth edge transitions.
* **Target File**: `app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart`

### C. Database Node Coordinate Collision (Issue #39)
* **Problem**: Root nodes share identical seeder coordinates in database_initializer.dart, causing them to render on top of each other.
* **Fix**: Calculate dynamic coordinate offsets for root nodes during database seeding.
* **Target File**: `app_flutter/lib/domain/database_initializer.dart`

### D. Stuck Loading Spinner (Issue #38)
* **Problem**: Empty/failed datasets do not terminate the view model's loading state in tabbed_container.dart and tables_view_model.dart, leaving the loading spinner active indefinitely.
* **Fix**: Force the loading state to complete and notify listeners in error/empty code paths.
* **Target Files**: `app_flutter/lib/features/tables/view_models/tables_view_model.dart` and `app_flutter/lib/features/tables/tabbed_container.dart`

---

## 3. Detailed Execution Matrix (Who, What, Where, When, and How)

| Phase | Step | Action | Executing Role | Target Path / Command | Skill / Subagent Used |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Pre-flight** | **0.1** | Verify permissions table for unattended execution. | Coordinator | `list_permissions` | **[debug-protocol](skills/debug-protocol/SKILL.md)** |
| **Reproduction** | **1** | Write visual test and run both tests to capture failure logs (RED Phase). | **Reproduction Subagent** | [camera_gestures_navigation_test.dart](app_flutter/integration_test/camera_gestures_navigation_test.dart) / `flutter drive` | **[debug-protocol: Step 1 (Reproduction)](skills/debug-protocol/SKILL.md)** & **[execution-worker](skills/execution-worker/SKILL.md)** |
| **Hypothesis** | **2** | Analyze failures and generate ranked hypotheses. | **Hypothesis Subagent** | Analyze viewport/seeder code & error logs | **[debug-protocol: Step 2 (Hypothesis)](skills/debug-protocol/SKILL.md)** |
| **Investigation** | **3** | Binary-search and trace data flow from seeder to canvas. | **Investigation Subagent** | View model/viewport file analysis | **[debug-protocol: Step 3 (Investigation)](skills/debug-protocol/SKILL.md)** |
| **Evidence** | **4** | Compile logs, stack traces, and evidence dossier. | **Evidence Subagent** | Dossier compilation | **[debug-protocol: Step 4 (Evidence)](skills/debug-protocol/SKILL.md)** |
| **Root Cause** | **5** | Apply "5 Whys" to isolate root cause for all 4 defects. | **Root Cause Subagent** | Root cause analysis output | **[debug-protocol: Step 5 (Root Cause)](skills/debug-protocol/SKILL.md)** |
| **Fix** | **6** | Merge upstream fixes branch and rebuild packages graph. | **Fix Subagent** | `git merge origin/feat/backprop-flutter-source-changes` / `flutter pub get` | **[debug-protocol: Step 6 (Fix)](skills/debug-protocol/SKILL.md)** |
| **Verification** | **7** | Re-run integration tests directly to verify passing states (GREEN Phase). | **Verification Subagent** | `flutter drive` runs & linter audits | **[debug-protocol: Step 7 (Verification)](skills/debug-protocol/SKILL.md)** |
| **Sync & Close** | **7.1**| Reconcile issue checklists back to tracker, commit/push, and close defects. | Coordinator | `reconcile_backlog.py` / `git push` | **[spec-orchestrator](skills/spec-orchestrator/SKILL.md)** & **[project-constitution](skills/project-constitution/SKILL.md)** |
| **Loop Decision**| **8** | Assess loop closure or restart if any regression is found. | Coordinator | Final evaluation | **[debug-protocol: Step 8 (Loop)](skills/debug-protocol/SKILL.md)** |

---

## 4. Autonomous Loop Mechanics (How it Executes Unattended)
* **Start**: User types **`PROCEED`**.
* **Transition Sequence**:
  * Coordinator defines and spawns the `Reproduction Subagent` (Step 1) and ends turn.
  * Once the subagent finishes writing the test and running the RED tests, the system wakes the Coordinator up. Coordinator reads its report, spawns the `Hypothesis Subagent` (Step 2) and ends turn.
  * Repeat this sequence through each subagent step (Hypothesis -> Investigation -> Evidence -> Root Cause -> Fix -> Verification).
  * No user input will be requested during these transitions.
* **Pre-Flight Clearance**: All command prefixes (`git`, `gh`, `flutter`, `env`, `mkdir`) and the workspace path are pre-authorized on the active permissions table, preventing system prompts.

---

## 5. Verification Plan

### Automated Verification
* Visual and performance tests must execute with exit code 0.
* Spec coverage linter and backlog reconciliation scripts must pass with exit code 0.

### Manual Verification
* **Screenshots**: Verify that the following files are populated in `../screenshots/`:
  * `camera_initial_hud.png`
  * `camera_fly_to_node.png`
  * `camera_gesture_rotated.png`
* **Performance Logs**: Verify that 10 new JSON log lines are appended to [benchmark_results.jsonl](benchmark_results.jsonl).
