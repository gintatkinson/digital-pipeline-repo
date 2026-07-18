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

## 4. Fix Missing Parenthesis
- **app_flutter/lib/features/topology/scene_3d_viewport.dart**: Add missing closing parenthesis for `Positioned` after the `ListenableBuilder` block. Then run `flutter analyze`.

## 5. Fuji Node Label Collision & Database Hierarchy Fix
- **app_flutter/lib/features/topology/scene_3d_viewport.dart**: Track coordinates in `paint(Canvas canvas, Size size)` by adding `final Map<String, int> coordinateLabelCounts = {};` and applying an offset `Offset(8, -4 + count * 16.0)` to text nodes sharing the same coordinate block (`latDeg`, `lngDeg`).
- **app_flutter/lib/domain/database_initializer.dart**: In `create()`, execute a SQL UPDATE right before returning `db` to set `parent_node_id = 'L0 (Optical)'` for `node_id = 'node-SD_CH'` if it is missing or empty.
- Run tests (`flutter test test/topology/scene_3d_viewport_test.dart` and `scene_3d_viewport_golden_test.dart --update-goldens`) and `flutter analyze` inside `app_flutter`.
