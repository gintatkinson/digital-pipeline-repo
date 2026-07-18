# Implementation Plan: Refactor Visual Test Verification

This plan addresses the test suite blindspot where integration tests pass blindly without verifying that the 3D globe and tiles are actually rendered on screen. We will refactor the test suite to assert tile cache state, add a dynamic wait loop, and perform a pixel-level color variance check on screenshots. We will also add unit tests verifying the projection math for space, surface, and altitude.

## 1. Goal Description
Refactor the integration test `camera_gestures_navigation_test.dart` to:
1. Wait dynamically for tiles to load and decode.
2. Assert that the tile cache is populated.
3. Compute standard deviation of pixel color values on screenshots to detect blank rendering.
4. Verify through TDD RED-GREEN verification that the test fails when tiles do not render, and passes when they do.
5. Verify that tiles are rendered correctly in space, on the surface, and in altitude (incorporating elevation and vertical exaggeration offsets) by adding unit tests.
6. Open up the topology view by increasing the overall screen size in the integration test to 1920x1080.

## 2. Target Files & Proposed Changes

### [globe_tile_renderer.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/cesium_3d/globe_tile_renderer.dart)
* Add a public getter for testing:
  ```dart
  @visibleForTesting
  int get loadedImagesCount => _loadedImages.length;
  ```

### [camera_gestures_navigation_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/camera_gestures_navigation_test.dart)
1. **Dynamic Tile Loaded Await**:
   * Add a helper method `waitForTilesToLoad(WidgetTester tester, Scene3DViewportState state)` that polls `state.tileRenderer?.loadedImagesCount` and waits (up to a timeout, e.g. 5 seconds) until it is greater than zero.
2. **Pixel Color Variance Assertion**:
   * Implement a standard deviation check (`stdDev`) on the raw PNG bytes returned from the screenshot.
   * Decode PNG bytes using `ui.instantiateImageCodec` and convert to raw RGBA bytes using `toByteData(format: ui.ImageByteFormat.rawRgba)`.
   * Extract R, G, B color values and calculate their standard deviation.
   * Assert that the standard deviation is greater than 15.0 to verify that a blank, solid-color screen is not rendered.
3. **Screenshot Verification wrapper**:
   * Modify the screenshot method to perform the standard deviation check.
4. **Increase Surface/Screen Size**:
   * Change `tester.binding.setSurfaceSize(const Size(1280, 800))` to `const Size(1920, 1080)` to open up the topology view.

### [globe_tile_renderer_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/cesium_3d/globe_tile_renderer_test.dart)
* Add a new test case: `Scenario 8 - Tile projection verification: space, surface, and altitude with elevation and exaggeration`.
* Assert space height projection, surface height projection with elevation, and vertical exaggeration scaling. Use absolute camera altitudes (e.g. `6378137.0 + 50000.0`) to avoid WGS84 horizon culling.

---

## 3. Verification Plan

### TDD RED Phase (Failing Test)
1. Set `TileFetcher.urlOverride` to an invalid or empty value (or clear/disable the tile fetcher) inside the test.
2. Run the drive test:
   ```bash
   env SCREENSHOT_DIR=/Users/perkunas/jail/digital-pipeline-repo/screenshots flutter drive --driver=test_driver/integration_test.dart --target=integration_test/camera_gestures_navigation_test.dart -d macos
   ```
3. Verify that the test fails due to the standard deviation assertion (blank screen). (COMPLETED: Verified in task-60 logs).

### TDD GREEN Phase (Passing Test)
1. Restore the correct tile URL override configuration so that tiles load successfully.
2. Run the drive test again.
3. Verify that the test successfully passes, proving that both the loading wait loop and standard deviation check work correctly.

### Unit Tests Verification
1. Run all cesium_3d unit tests to verify the new projection assertions:
   ```bash
   flutter test test/cesium_3d/globe_tile_renderer_test.dart
   ```
