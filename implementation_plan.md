# Implementation Plan - Issue #69 Design Tokens Integration

This plan details copying, registering, parsing, and resolving the design tokens from logical-ui to the app_flutter codebase, replacing all hardcoded color references.

## Proposed Changes

### 1. Copy `design-tokens.json`
- Copy `.pipeline/logical-ui/design-tokens.json` to `app_flutter/assets/design-tokens.json`.

### 2. Update `app_flutter/pubspec.yaml`
- Register `assets/design-tokens.json` under the `assets:` section.

### 3. Create `app_flutter/lib/domain/design_tokens.dart`
- Implement `DesignTokenRegistry` interface and a concrete implementation class.
- Support recursive alias syntax parsing (e.g. `{global.color.blue-500}`).
- Support theme-dependent values (`light` and `dark`).
- Support parsing dimensions (e.g., "16px" -> 16.0) and colors (e.g., "#1a73e8" -> 0xFF1A73E8).

### 4. Update `app_flutter/lib/main.dart`
- Load `design-tokens.json` asynchronously on startup inside `main()`.
- Initialize `DesignTokenRegistry` with the loaded JSON.
- Provide the registry to the widget tree using an InheritedWidget or similar state provider.
- Dynamically resolve ThemeData using the design tokens.
- Replace all hardcoded colors with registry-resolved values.

### 5. Update `app_flutter/lib/components/layout.dart`
- Retrieve `DesignTokenRegistry` from context.
- Update layout sizing (sidebar width, splitter min size) and all hardcoded color values to be resolved dynamically.

### 6. Update `app_flutter/lib/components/breadcrumbs.dart`
- Retrieve `DesignTokenRegistry` from context.
- Resolve breadcrumb colors dynamically.

### 7. Update `app_flutter/lib/components/property_grid.dart`
- Retrieve `DesignTokenRegistry` from context.
- Resolve property grid colors dynamically.

## Verification Plan

### Automated Verification Steps
1. Run `flutter analyze` inside `app_flutter/` to verify zero static analysis warnings.
2. Run `flutter test` inside `app_flutter/` to verify all tests pass.
3. Verify remote push and branch synchronization.


# Implementation Plan - Issue #70 Dynamic Workspace Split Layout Orientation Toggle

This plan details implementing a setting to dynamically switch the workspace split layout between horizontal and vertical orientations, persisting the user preference, and binding it to the UI settings panel.

## Proposed Changes

### 1. In `app_flutter/lib/core/theme/theme_service.dart`
- Add `Future<Axis> loadLayoutSplitAxis();` and `Future<void> saveLayoutSplitAxis(Axis axis);` to `ThemeService`.
- Implement them in `SharedPreferencesThemeService` using key `'layout_split_axis'` and storing values `'horizontal'` or `'vertical'`. Use `Axis.horizontal` as the default.

### 2. In `app_flutter/lib/core/theme/theme_controller.dart`
- Add private field `Axis _layoutSplitAxis = Axis.horizontal`.
- Add getter `Axis get layoutSplitAxis => _layoutSplitAxis`.
- Load this preference in `loadSettings()`.
- Add `Future<void> updateLayoutSplitAxis(Axis newAxis)` that updates the state, notifies listeners, and calls `saveLayoutSplitAxis` on the service.

### 3. In `app_flutter/lib/features/layout/component_factory.dart`
- Accept `preferredSplitAxis` (an optional `Axis?`) in the `ComponentFactory` constructor and store it.
- In `build()`, if `preferredSplitAxis` is non-null, override the `direction` of the `SplitWorkspace` (for `SplitWorkspace` and `TopographicalView` containers) with `preferredSplitAxis`.

### 4. In `app_flutter/lib/features/layout/layout.dart`
- Watch `ThemeController` in `_buildFromLayout` and retrieve the preferred layout split axis.
- Pass this preferred axis to the `ComponentFactory`.

### 5. In `app_flutter/lib/core/theme/widgets/settings_panel.dart`
- Add a section titled "Workspace Split" showing a `SegmentedButton` to switch between Horizontal and Vertical split layout.
- Bind this SegmentedButton to `themeController.layoutSplitAxis` and `themeController.updateLayoutSplitAxis()`.

### 6. In `app_flutter/test/layout_test.dart`
- Adjust the test window physical size to `1200x800` in tests that default to smaller screen sizes to prevent layout overflow errors when the workspace split axis defaults to horizontal.

## Verification Plan

### 1. Unit Tests
- Add unit tests in `app_flutter/test/core/theme/theme_controller_test.dart` (or create a new test file if needed) verifying `ThemeController` loads, updates, and saves `layoutSplitAxis` properly.

### 2. Automated Runs
- Run `flutter analyze` inside `app_flutter/` to verify zero static analysis warnings.
- Run `flutter test` inside `app_flutter/` to verify all tests pass.

