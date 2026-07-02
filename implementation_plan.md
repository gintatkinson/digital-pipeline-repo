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


# Implementation Plan - De-hardcoding Alarms/Events (Domain & Data Source Layers)

This plan details the implementation of the Domain and Data Source layers to support generic parent-child queries (`fetchRelatedInstances`) instead of hardcoded type-specific methods.

## Proposed Changes

### 1. Create `app_flutter/lib/domain/instance_record.dart`
- Define the `InstanceRecord` model with `id`, `parentNodeId`, `typeName`, and `attributes`.
- Implement `fromMap` factory.

### 2. Modify `app_flutter/lib/domain/data_source.dart`
- Remove `fetchElements`, `fetchAlarms`, and `fetchEvents`.
- Add `fetchRelatedInstances` returning `Future<List<InstanceRecord>>`.

### 3. Modify `app_flutter/lib/domain/data_sources/sqlite_data_source.dart`
- Implement `fetchRelatedInstances` to query the SQLite table based on `targetType.typeName`.
- Map results to `InstanceRecord`.
- Remove `fetchElements`, `fetchAlarms`, and `fetchEvents`.

### 4. Modify `app_flutter/lib/domain/data_sources/firebase_data_source.dart`
- Implement `fetchRelatedInstances` to query the Firestore collection based on `targetType.typeName`.
- Map results to `InstanceRecord`.
- Remove `fetchElements`, `fetchAlarms`, and `fetchEvents`.

### 5. Delete `app_flutter/lib/domain/data_sources/fallback_data_source.dart`
- Delete the fallback data source as it is no longer needed.

### 6. Modify `app_flutter/lib/domain/repository_resolver.dart`
- Remove all imports and references to `FallbackDataSource`.
- Remove the `typeCount` check and always return `SqliteDataSource(db)`.

## Verification Plan

### 1. Compilation check
- Verify all modified files compile successfully without errors or warnings.


# Implementation Plan - De-hardcoding Alarms/Events (View Model & Presentation Layers)

This plan details refactoring the View Model and Presentation layers to fully adopt dynamic, metadata-driven tab discovery and data rendering.

## Proposed Changes

### 1. Refactor `app_flutter/lib/features/tables/view_models/tables_view_model.dart`
- Update `TabDescriptor` class structure to hold `TypeDescriptor type` directly.
- In `loadForNode`, retrieve child and related `TypeDescriptor`s via `_dataSource.typeFor(childTypeName)`, instantiating `TabDescriptor` with the fetched `type`.
- In `_loadData`, query related instances via `_dataSource.fetchRelatedInstances(parentNodeId: _activeView, targetType: tab.type)`.
- Map `records` to cell lists dynamically using `tab.type.fields`.

### 2. Refactor `app_flutter/lib/features/layout/layout_config_service.dart`
- Remove hardcoded fallback dictionary from `resolveLabelsMapping`, replacing it with `const <String, String>{}`.

### 3. Refactor `app_flutter/lib/features/layout/layout.dart`
- Remove hardcoded checks for `sub_elements_table`, `active_alarms_table`, and `historical_events_table` in `_resolveTabLabel`.
- Implement Title Case conversion mapping for underscores in `tabId`.

## Verification Plan

### 1. Static Analysis
- Run `flutter analyze` inside `app_flutter/` to verify zero compile or analysis warnings.

### 2. Verification
- Verify that tests compile and pass.


# Implementation Plan - Refactor Automated Test Suites to SQLite

This plan details refactoring the automated test suites in layout_test.dart and widget_test.dart to run against a real, seeded in-memory SQLite database instead of the deprecated FallbackDataSource.

## Proposed Changes

### 1. In `app_flutter/test/layout_test.dart`
- Remove all references and imports of `FallbackDataSource`.
- Add imports:
  - `package:sqflite_common_ffi/sqflite_ffi.dart`
  - `package:app_flutter/domain/database_initializer.dart`
  - `package:app_flutter/domain/data_sources/sqlite_data_source.dart`
- Implement helper function `Future<Database> createTestDatabase() async` with custom seeding of type definitions, type attributes, type relations, properties, elements, alarms, and events.
- Update `wrapWithRepo` signature to accept a `DataSource dataSource` instead of using the hardcoded `FallbackDataSource()`.
- Update all five `testWidgets` test cases:
  - Wrap the setup and test execution in `tester.runAsync()`.
  - Inside `runAsync`, initialize the database using `createTestDatabase()`.
  - Register `addTearDown(() => db.close())` inside `runAsync`.
  - Instantiate `SqliteDataSource(db)` and pass it as the provider `DataSource`.
  - Update layout test assertions to search for `'Active View: Item'` and keys `'SubElement-table'`, `'Alarm-table'`, `'Event-table'`.

### 2. In `app_flutter/test/widget_test.dart`
- Remove all references and imports of `FallbackDataSource`.
- Add import `package:app_flutter/domain/data_sources/sqlite_data_source.dart`.
- Change the provider `DataSource` to `SqliteDataSource(db)`.
- Change the database initialization to seed the in-memory database using `DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: true)`.

### 3. In mock data sources within table tests
- Update `_MockDataSource` inside `tables_view_model_test.dart`, `table_view_widget_test.dart`, and `data_table_benchmark_test.dart`:
  - Remove deprecated methods `fetchElements`, `fetchAlarms`, and `fetchEvents`.
  - Add import `package:app_flutter/domain/instance_record.dart`.
  - Implement `fetchRelatedInstances` returning mocked `InstanceRecord` lists matching the expected test data.

## Verification Plan

### 1. Automated Execution
- Run `flutter test` inside the `app_flutter/` directory to verify that all 89 test cases execute and pass successfully.
- Verify that `git diff origin/restore-june30` contains only the intended changes.
