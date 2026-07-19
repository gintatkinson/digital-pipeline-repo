# Implementation Plan: Fix Incorrect LOD Masking in Globe Tile Renderer

This plan details the steps to file the defect issue, apply the code correction to comment out incorrect LOD masking, rebuild the macOS release, package it, run backlog reconciliation, and push the branch.

## 1. Proposed Changes

### Component: Upstream Defect Reporting
* **Action**: Create a temporary file `scratch/render_issue.md` containing the defect details, and run the `gh` command to file the issue on the repository.
* **Target File**: `scratch/render_issue.md` (temporary)

### Component: Globe Tile Renderer Code Correction
* **Action**: Comment out the LOD masking check so parent tiles are always drawn as a base layer and child tiles are drawn on top using Painter's Algorithm.
* **Target File**: `app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart`
* **Changes**:
```diff
      // LOD masking: skip this tile if a higher-zoom child tile is loaded.
-      if (_hasHigherZoomOverlay(TileCoord(zoom: z, x: x, y: y))) continue;
+      // if (_hasHigherZoomOverlay(TileCoord(zoom: z, x: x, y: y))) continue;
```

---

## 2. Execution & Verification Steps

### Step 1: Create Defect Description File
Write character-for-character contents to `scratch/render_issue.md`.

### Step 2: File Defect on GitHub
Run the command:
```bash
gh issue create --repo gintatkinson/digital-pipeline-repo --title "[AUDIT] [globe_tile_renderer.dart]: Map tile sectors and wedges are missing due to incorrect LOD masking [GLOBE-LNT-01]" --label "bug" --body-file scratch/render_issue.md
```

### Step 3: Apply Code Correction
Edit `app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart` and comment out line 337.

### Step 4: Rebuild the Production Release
Run the command inside `app_flutter` directory:
```bash
flutter build macos --release
```

### Step 5: Repackage the Distributable Zip
Run the command inside `app_flutter/build/macos/Build/Products/Release/` directory:
```bash
zip -r -y ../../../../../app_flutter_release.zip app_flutter.app
```

### Step 6: Stage, Commit, Reconcile, and Push
1. Stage the file: `git add app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart`
2. Commit: `git commit -m "fix: comment out broken LOD masking in globe_tile_renderer.dart"`
3. Run reconciliation: `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`
4. Push to origin: `git push origin feat/58-63-linter-fixes`

### Step 7: Launch the Updated App
Run the command inside `app_flutter/build/macos/Build/Products/Release/` directory:
```bash
open app_flutter.app
```

### Step 8: Clean Up Temporary Files
Remove the temporary issue file:
```bash
rm -f scratch/render_issue.md
```
