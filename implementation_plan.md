# Implementation Plan: Refactor Visual Test Verification

This plan addresses the test suite blindspot where integration tests pass blindly without verifying that the 3D globe and tiles are actually rendered on screen. We will refactor the test suite to assert tile cache state, add a dynamic wait loop, and perform a pixel-level color variance check on screenshots. We will also add unit tests verifying the projection math for space, surface, and altitude.

## 1. Goal Description
Refactor the integration test `camera_gestures_navigation_test.dart` to:
1. Ensure the 3D globe has tiles fully rendered by waiting for the tile renderer's cache to load all visible tiles (waiting for the image count to reach a stable state, e.g. at least 4 loaded tiles and no count increases for 500ms).
2. Call the wait loop `waitForTilesToLoad()` **before every single screenshot** (initial HUD, fly-to-node, and rotated globe) instead of only the first one.
3. Compute standard deviation of pixel color values on screenshots to detect blank rendering.
4. Verify through TDD RED-GREEN verification that the test fails when tiles do not render, and passes when they do.
5. Verify that tiles are rendered correctly in space, on the surface, and in altitude (incorporating elevation and vertical exaggeration offsets) by adding unit tests.
6. Open up the topology view by increasing the overall screen size in the integration test to 1920x1080.

## 2. Target Files & Proposed Changes

### [camera_gestures_navigation_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/integration_test/camera_gestures_navigation_test.dart)
* **Refactor `waitForTilesToLoad`**:
  Update the method to wait until `loadedImagesCount >= 4` and has stabilized (remaining constant for 5 consecutive frames/500ms).
* **Inject Await in All Stages**:
  Add `await waitForTilesToLoad()` before:
  - `takeScreenshot('camera_initial_hud')`
  - `takeScreenshot('camera_fly_to_node')`
  - `takeScreenshot('camera_gesture_rotated')`

---

## 3. Verification Plan

### TDD RED Phase (Failing Test)
1. Configure an invalid template inside the integration test or disable the tile fetcher.
2. Run the drive test and verify failure.

### TDD GREEN Phase (Passing Test)
1. Run the drive test.
2. Verify that the test successfully passes and captures all three screenshots with tiles fully rendered.
