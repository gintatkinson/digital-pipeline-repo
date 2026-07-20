# Implementation Plan: Asynchronous glTF Model Loader & Real I/O Tests

This plan outlines the implementation of a robust, asynchronous binary glTF/glb loader mapped directly to the four sequential phases specified in the prompt.

## User Review Required

> [!IMPORTANT]
> **No Mocking Directive**: Mockito, Mocktail, dummy 1-byte files, or fake asset bundle bindings are strictly forbidden. All operations and unit tests must execute against real file I/O using the existing populated SQLite database (`properties_db.db`).

## Open Questions

None. The task phases are executed in order below.

---

## Proposed Changes

### Phase 1: Refactor for Asynchronous I/O
* **Target File**: [scene_3d_viewport_classes.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport_classes.dart) (Lines 1–15, 530–541)
* **Changes**:
  - Add `import 'dart:typed_data';` to support binary data structures.
  - Modify `Network3DScene`:
    - Change `String gltfData` to `Uint8List? gltfData` to represent the binary glTF format.
    - Change the signature of `loadModel(String modelPath)` to `Future<bool> loadModel(String modelPath)`.
    - Implement asset byte loading using `rootBundle.load(modelPath)` and convert the returned `ByteData` to `Uint8List` using `asUint8List()`.

### Phase 2: Error Handling & Data Validation
* **Target File**: [scene_3d_viewport_classes.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport_classes.dart) (Lines 533–542)
* **Changes**:
  - Wrap the `rootBundle.load(modelPath)` binary loading operation in a robust try-catch block.
  - Implement validation checks:
    - Return `false` immediately if `modelPath` is empty.
    - Check if the loaded `Uint8List` is empty (length == 0). If empty, return `false`.
    - Ensure the method strictly returns `false` on any exception or invalid data, and `true` only when bytes are successfully extracted.

### Phase 3: PBR Material State Management
* **Target File**: [scene_3d_viewport_classes.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport_classes.dart) (Lines 528–530, 543–548)
* **Changes**:
  - Define the lifecycle tracking enum:
    ```dart
    enum ModelRenderState { unloaded, loading, loaded, error }
    ```
  - Add `ModelRenderState state = ModelRenderState.unloaded;` inside `Network3DScene`.
  - Update `state` during `loadModel` execution:
    - Set state to `ModelRenderState.error` if the path is empty.
    - Set state to `ModelRenderState.loading` when starting standard asset loading.
    - Set state to `ModelRenderState.loaded` when bytes are successfully validated and stored in `gltfData`.
    - Set state to `ModelRenderState.error` if loading catches an exception or fails validation.
  - Refactor `applyPbrMaterials()`:
    - Enforce that it only sets `isTranslucent = true` and returns `true` if `state == ModelRenderState.loaded` and `gltfData != null`. Otherwise, return `false`.

### Phase 4: Real I/O Unit Testing with the Database
* **Target File**: [network_3d_scene_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/cesium_3d/network_3d_scene_test.dart) [NEW]
* **Changes**:
  - Initialize the SQLite database connection inside `setUpAll` using the FFI database factory (`sqfliteFfiInit()`, `databaseFactory = databaseFactoryFfi`).
  - Query `assets/properties_db.db` to extract a valid registered asset model path.
  - **Success Test**: Call `loadModel` using the database-retrieved path. Assert that it successfully reads the bytes, returns `true`, and sets `state` to `ModelRenderState.loaded`.
  - **Failure Test**: Call `loadModel` with a non-existent path. Assert that it catches the file exception gracefully, returns `false`, and sets `state` to `ModelRenderState.error`.
  - **State Test**: Call `applyPbrMaterials()` before loading has occurred. Assert that it returns `false` safely without setting `isTranslucent = true`.

### Phase 5: Lint Fixes
* **Target File**: [network_3d_scene_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/cesium_3d/network_3d_scene_test.dart)
* **Changes**:
  - Remove unused import `package:flutter/services.dart`.

---

## Verification Plan

### Automated Tests
- Run the newly created unit test suite:
  ```bash
  flutter test test/domain/cesium_3d/network_3d_scene_test.dart
  ```
- Run the full verification baseline pipeline script:
  ```bash
  python3 scripts/verify_downstream_baseline.py
  ```
