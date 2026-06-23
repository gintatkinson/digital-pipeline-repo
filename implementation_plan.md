# Implementation Plan - Stack-positioned Floating Scrollbars in Topology Map

Implement Stack-positioned floating scrollbars in `/Users/perkunas/digital-pipeline-repo/app_flutter/lib/components/topology_map.dart` to support synchronized bidirectional vertical and horizontal scrolling.

## Proposed Changes

### 1. `app_flutter/lib/components/topology_map.dart`
- **State Properties:**
  - Declare `_contentVerticalController`, `_scrollbarVerticalController`, `_contentHorizontalController`, and `_scrollbarHorizontalController`.
  - Declare boolean flags `_isSyncingVertical = false` and `_isSyncingHorizontal = false`.
- **Initialization (`initState`):**
  - Initialize the 4 scroll controllers.
  - Set up bidirectional scroll listeners with re-entry guard flags:
    - Sync `_scrollbarVerticalController` to `_contentVerticalController` and vice versa.
    - Sync `_scrollbarHorizontalController` to `_contentHorizontalController` and vice versa.
- **Disposal (`dispose`):**
  - Dispose all four scroll controllers.
- **Widget Hierarchy (`build`):**
  - Replace the current nested `Scrollbar` layout within the `Expanded` widget with a `Stack`.
  - **Layer 1: Main Content**
    - Wrapped in `Positioned.fill`.
    - Contains the nested `SingleChildScrollView` widgets without their wrapping `Scrollbar` widgets.
    - Connect the scroll views to `_contentVerticalController` and `_contentHorizontalController`.
  - **Layer 2: Vertical Floating Scrollbar**
    - Wrapped in `Positioned(right: 0, top: 0, bottom: 12, width: 12)`.
    - Contains a `Scrollbar` configured with `controller: _scrollbarVerticalController` and `thumbVisibility: true`.
    - Wraps a `SingleChildScrollView` configured with `controller: _scrollbarVerticalController`, `scrollDirection: Axis.vertical`, and child `SizedBox(height: height)`.
  - **Layer 3: Horizontal Floating Scrollbar**
    - Wrapped in `Positioned(left: 0, right: 12, bottom: 0, height: 12)`.
    - Contains a `Scrollbar` configured with `controller: _scrollbarHorizontalController` and `thumbVisibility: true`.
    - Wraps a `SingleChildScrollView` configured with `controller: _scrollbarHorizontalController`, `scrollDirection: Axis.horizontal`, and child `SizedBox(width: width)`.
  - **Theme Wrapper:**
    - Ensure the custom `ThemeData.dark()` scrollbar theme wraps the entire `Stack` (or the scrollbars) so the custom scrollbars are styled correctly.

### 2. `app_flutter/test/topology_map_test.dart`
- Update the widget test that checks `find.byType(SingleChildScrollView)`:
  - Increase the expected count of `SingleChildScrollView` widgets from 2 to 4 since the two new floating scrollbars use `SingleChildScrollView` wrappers to achieve synchronized scrolling.

## Verification Plan

### Automated Tests
1. Run `flutter analyze` inside `app_flutter` to verify there are no compilation errors or lint issues.
2. Run `flutter test` inside `app_flutter` to ensure all tests pass (specifically the topology map layout and interaction tests).

### Manual Verification
1. Drag the main content horizontally/vertically and verify the custom scrollbar thumb moves.
2. Drag the scrollbar thumb and verify the canvas content scrolls accordingly.
