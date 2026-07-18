# Handoff Report: Visual Defect Remediation & Git History Purge

This document provides a clean roadmap and context transfer for the next agent to successfully resolve the visual, layout, coordinate, and loading spinner defects.

---

## 1. Current State of Repository
*   **Git History Purge Completed**: The bloated commit containing `web_react/node_modules/` (1.35 million lines of dependencies) has been completely purged from the Git history on both the local and remote branches on GitHub.
*   **Synchronized Baseline**: The local branch matches `origin/main` exactly, and the working tree is 100% clean.
*   **Exclusions Configured**: Root `.gitignore` has been updated to permanently exclude `node_modules/` and build files.

---

## 2. Codebase Visual & Rendering Defects (Remediation Mandate)

The next agent **MUST** implement the following codebase fixes to resolve the defects:

### A. Viewport Paint Overdraw/Bleeding
*   **Defect**: The 3D globe and line drawings bleed outside the viewport boundaries, rendering on top of the divider and properties panel.
*   **Target File**: `app_flutter/lib/features/topology/scene_3d_viewport.dart`
*   **Required Fix**: Add `canvas.clipRect(Offset.zero & size);` at the very beginning of the `paint` method in `Scene3DViewportPainter` to restrict all drawing operations to the viewport layout bounds.

### B. Flat Seams Patchwork & Brightness/Color Discontinuity
*   **Defect**: Tile boundaries show straight rectangular seam lines instead of curving along the globe, along with stark brightness/color mismatches.
*   **Target File**: `app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart`
*   **Required Fix**: Modify the subdivisions logic in `GlobeTileRenderer.renderTiles` (around L327) to use a high subdivisions count of `16` for all visible tiles. This increases mesh vertex density, warping boundaries along the sphere. Additionally, adjust the base planet sphere colors in `Scene3DViewportPainter.paint` (L1653) to blend with the satellite map.

### C. Database Node Coordinate Collision
*   **Defect**: All non-root nodes are hardcoded to the exact same coordinates and sea-level height, causing them to overlap completely.
*   **Target File**: `app_flutter/lib/domain/database_initializer.dart`
*   **Required Fix**: Replace the hardcoded New York coordinates for non-root nodes (L247) with an index-distributed offset (e.g. `40.7128 + nodeIndex * 0.05`) to spread them out geographically and vertically.

### D. Stuck Loading Spinner
*   **Defect**: An infinite progress indicator spins when loading tables.
*   **Target Files**: `app_flutter/lib/features/tables/view_models/tables_view_model.dart` and `app_flutter/lib/features/tables/tabbed_container.dart`
*   **Required Fix**: Ensure the `loading` flag is correctly set to false on configuration load errors or empty datasets.

---

## 3. Protocol for Next Agent (Strict Compliance)

The next agent **MUST** follow these steps exactly:
1.  **Read Customizations First**: Re-read `.agents/AGENTS.md` and check active skills (`debug-protocol` and `feature-driven-implementation`).
2.  **Pre-flight Permissions**: Execute `ask_permission` at the start of the session to pre-authorize `command` prefixes for `flutter`, `git`, and `gh`.
3.  **Execute Debug Protocol Loop**: Do NOT apply ad-hoc repairs. Run through the 8-step Debug Protocol sequentially:
    - *Step 1*: Spawn a reproduction subagent to execute `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/visual_rendering_defect_test.dart` and capture the expected failure screenshots.
    - *Step 2-5*: Spawn hypothesis, investigation, evidence, and root-cause subagents.
    - *Step 6*: Spawn a fix subagent to implement the required fixes detailed above.
    - *Step 7*: Spawn a verification subagent to confirm the visual tests pass.
