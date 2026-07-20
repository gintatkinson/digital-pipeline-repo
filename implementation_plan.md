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
