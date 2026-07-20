# Implementation Plan: Topology 3D Model Integration

This plan details the integration of the asynchronous glTF loader into `SceneViewState` and `TopologyLayer` to render 3D assets for specific network nodes with standard 2D fallback paths.

## User Review Required

> [!IMPORTANT]
> **No Mocking Directive**: Mockito, Mocktail, or fake data stubs are forbidden. The test suite must query the real database and perform actual asset bundle reads.

## Open Questions

None. The execution phases match the prompt sequentially.

---

## Proposed Changes

### Phase 1: Model State Integration in SceneViewState
- Add a mapping dictionary member to `SceneViewState` in `scene_3d_viewport_classes.dart`:
  ```dart
  final Map<String, Network3DScene> nodeModels = {};
  ```
- In the node projection or topology loading pipeline (`setTopologyData` or `updateNodeProjections`), evaluate if a node requires a 3D model:
  - A node requires a 3D model if it has a non-empty `model_path` (or `model`) property inside its `rawProperties` mapping.
- For each eligible node:
  - If it is not present in `nodeModels`, instantiate a new `Network3DScene`.
  - Put the scene instance into `nodeModels[node.id]`.
  - Trigger `loadModel(modelPath)` asynchronously.
  - Upon completion of `loadModel`, trigger `notifyListeners()` so the CustomPainter reactively triggers a repaint once the model transitions to `loaded` or `error`.

### Phase 2: TopologyLayer Rendering Update
- In `TopologyLayer.paint` inside `scene_3d_viewport.dart`:
  - Check `state.nodeModels[node.id]` for an associated `Network3DScene`.
  - If a model is mapped, check if `model.state == ModelRenderState.loaded` and `model.gltfData != null`.
  - If **loaded**:
    - Bypass the standard 2D circle drawing commands.
    - Render a 3D visual representation (such as a shaded octahedron or diamond shape using `canvas.drawPath` to represent the glTF model) at `proj.offset`.
  - If **loading**, **error**, or **unloaded**:
    - Gracefully fall back to the standard 2D circles (`_satNodeGlowPaint`, `_satNodePaint`, `_innerWhitePaint`).

### Phase 3: Integration Testing
- Extend the integration tests in `test/domain/cesium_3d/network_3d_scene_test.dart`:
  - **Test 1 (Successful 3D Render)**: Inject a node with a valid database model path into the state. Trigger the loader and assert that `TopologyLayer.paint` executes without throwing, and identifies the node state as loaded (bypassing the circle paints).
  - **Test 2 (Fallback 2D Render)**: Inject a node with an invalid model path. Verify that after loading fails, the model transitions to the `error` state and the layer defaults to the standard 2D circle rendering logic.
