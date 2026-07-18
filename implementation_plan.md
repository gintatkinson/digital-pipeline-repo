# Implementation Plan: Flutter 3D Rendering Performance Fixes

## 1. Overview
The goal is to fix severe performance bottlenecks in `Scene3DViewportState` and `Scene3DViewportPainter` by updating star allocation, removing unnecessary CPU rebuilds/overdraw, and implementing an LRU cache for `TextPainter`.

## 2. Changes
- **app_flutter/lib/features/topology/scene_3d_viewport.dart**:
  - In `Scene3DViewportState`, remove `setState({})` from `_onCameraChangedInside`.
  - In `Scene3DViewportState.build()`, remove `repaint: _cameraController` from the `CustomPaint` instantiation and instead pass it as `repaint: _cameraController` to the `Scene3DViewportPainter` constructor.
  - Remove `BackdropFilter` widgets in the HUD and replace them with `Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)))`.
  - In `Scene3DViewportPainter`:
    - Add `final Listenable? repaint;` field.
    - Add `this.repaint,` as an optional parameter to the constructor.
    - Forward it to the super constructor via `super(repaint: repaint)` in the initializer list.
    - Add `static final List<(double, double, double, double)> _stars = ...` block for star positions and update `paint()` to iterate over `_stars` instead of recreating random values every frame.
  - In `_TextPainterCache`, update `getOrCreate` to implement a true LRU cache by removing and re-inserting the cache entry on hit.

## 3. Verification
- Verify the build passes cleanly.
- (If necessary) Run any flutter integration or unit tests covering this area.

