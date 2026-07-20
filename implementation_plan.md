# Implementation Plan: Refactoring Network3DScene

## Overview
Refactor `Network3DScene` to support asynchronous glTF/glb loading, implement proper error handling and data validation, introduce PBR material state management, and write mock-free, database-backed unit tests.

## Phases

### Phase 1: Refactor for Asynchronous I/O
- Modify `Network3DScene` class in the existing file.
- Update `gltfData` to use `Uint8List` (from `dart:typed_data`) instead of `String`.
- Update `loadModel(String modelPath)` signature to `Future<bool> loadModel(String modelPath)`.
- Use `rootBundle.load(modelPath)` to load the binary file and extract a `Uint8List`.

### Phase 2: Error Handling & Data Validation
- Enclose `rootBundle.load` in a `try-catch` block.
- Validate `modelPath` (not empty).
- Validate `Uint8List` (length > 0).
- Return `false` gracefully on error/invalid data, `true` on success.

### Phase 3: PBR Material State Management
- Create `ModelRenderState` enum: `unloaded`, `loading`, `loaded`, `error`.
- Update state inside `loadModel`.
- Update `applyPbrMaterials()` to set `isTranslucent = true` only if state is `loaded` and `gltfData` is not null (and return a value / handle execution safely otherwise).

### Phase 4: Real I/O Unit Testing with the Database
- Create `test/domain/cesium_3d/network_3d_scene_test.dart` under `app_flutter/` (following directory constraints).
- Use `setUpAll` to connect to `properties_db.db` and query a real model path.
- Test 1: Success test loading a valid asset from DB. Assert successful read, returns true, and `loaded` state.
- Test 2: Failure test using a non-existent path. Assert exception caught, returns false, and `error` state.
- Test 3: State test asserting `applyPbrMaterials()` behavior before I/O completes.

Please review this implementation plan and provide your explicit approval so I can proceed with the execution.
