# Implementation Plan: Isolated Fault Tolerance & Generic Seeding

This plan details the changes to implement isolated fault tolerance boundaries across external services and refactor the SQLite database seed logic to use a domain-free string template generation scheme.

---

## Part 1: Isolated Fault Tolerance & Service Recovery

To ensure that external plugin, network, or database failures are isolated and resolved with clean defaults rather than crashing the application runtime, we will wrap the following boundary layers:

### 1. SQLite Data Source
- **File**: `app_flutter/lib/domain/data_sources/sqlite_data_source.dart`
- **Remedy**: Wrap all database queries (`discoverTypes`, `typeFor`, `discoverHierarchy`, `fetchProperties`, and `fetchRelatedInstances`) in `try-catch` blocks. If any exception is caught, log the error using `debugPrint` and return safe empty defaults (empty lists/maps or `null`).

### 2. Firebase Data Source
- **File**: `app_flutter/lib/domain/data_sources/firebase_data_source.dart`
- **Remedy**: Wrap all Firestore query and persistence operations in `try-catch` blocks, logging errors and recovering with empty defaults.

### 3. SharedPreferences Theme Service
- **File**: `app_flutter/lib/core/theme/theme_service.dart`
- **Remedy**: Wrap all `SharedPreferences` reads and writes inside `SharedPreferencesThemeService` in `try-catch` blocks. Fall back to standard defaults (e.g., `ThemeMode.system`, text scale `1.0`, index `0`) if the platform storage is corrupt, locked, or failing.

---

## Part 2: Generic Database Seeding via Template Generation

To remove all domain-specific words from the production database without requiring runtime whitelists or blacklists, we will refactor `database_initializer.dart` to generate the database vocabulary and records programmatically:

### 1. Types & Relations
- **Master Types**: `Master_A`, `Master_B`, `Master_C`
- **Detail Types**: `Detail_A`, `Detail_B`, `Detail_C`
- **Relations**: Every Master Type contains all three Detail Types as tabs.

### 2. Fields (Attributes)
- Every type has three fields: `field_1`, `field_2`, `field_3`

### 3. Properties (Data Values)
For any selected Master Node `[Master_Name]`, its field values are generated using the template:
- `val_[Master_Name]_[field_name]`
- *Example (for Master_A, field_1)*: `val_Master_A_field_1`

### 4. Detail Instances
For any Detail Type `[Detail_Name]` belonging to parent `[Master_Name]`, we generate $N$ instances (where `[index]` goes from $1$ to $N$) with:
- **Instance ID**: `inst_[Master_Name]_[Detail_Name]_[index]`
  * *Example*: `inst_Master_A_Detail_A_1`
- **Instance Field Value**: `val_inst_[Master_Name]_[Detail_Name]_[index]_[field_name]`
  * *Example*: `val_inst_Master_A_Detail_A_1_field_1`

### 5. Conditional FFI Initialization in Seed Database
- **File**: `app_flutter/lib/domain/database_initializer.dart`
- **Remedy**: In `DatabaseInitializer.create(...)`, initialize SQLite FFI conditionally only if we are in a test environment (`Platform.environment.containsKey('FLUTTER_TEST')`) or on non-mobile desktop (Windows/Linux/macOS) to support the local desktop macOS target while preventing FFI leakages on mobile platforms (iOS/Android).

### 6. Transience of In-Memory Database
- **File**: `app_flutter/lib/domain/database_initializer.dart`
- **Remedy**: Prevent `p.absolute(dbPath)` from converting the special sqlite `':memory:'` string to a persistent file path on disk when the path matches `inMemoryDatabasePath`.

---

## Part 3: Purge Legacy AbstractRepository Layer

To simplify the codebase and avoid architectural redundancy, we will remove `AbstractRepository` and inject `DataSource` directly into all consumers.

### 1. Delete File
- **File**: `app_flutter/lib/domain/repository.dart`
- **Action**: Delete completely.

### 2. Refactor Repository Injection & Dependency Resolution
- **Files**:
  - `app_flutter/lib/main.dart`
  - `app_flutter/lib/domain/repository_resolver.dart`
- **Action**: Remove references to `AbstractRepository` and return/inject `DataSource` directly.

### 3. Update Tests
- **Files**:
  - `app_flutter/integration_test/app_e2e_test.dart`
  - `app_flutter/test/layout_test.dart`
  - `app_flutter/test/widget_test.dart`
- **Action**: Replace `AbstractRepository` mocks or types with `DataSource` or `SqliteDataSource`/mock datasources.
- **Remedy for horizontal layout overflow in Widget Test**: Set viewport physical size to `1200x800` inside `widget_test.dart` to prevent default `800x600` sizing from failing with horizontal layout overflows.

---

## Part 4: Load 'Master_A' Instead of 'Item'

To align with the generic database seeding, the app shell and view models will load `Master_A` as the active view and exclude the detail types from tree representation.

### 1. Shell & View Model Updates
- **Files**:
  - `app_flutter/lib/app/app.dart`: Set `_activeView = 'Master_A'` instead of `Item`.
  - `app_flutter/lib/features/tree/view_models/tree_view_model.dart`: Set `_excludedTypes = {'Detail_A', 'Detail_B', 'Detail_C'}`.
  - `app_flutter/lib/features/tree/tree_defaults.dart`: Align `defaultTreeData` fallback hierarchy to `Master_A`, `Master_B`, and `Master_C`.
  - `app_flutter/assets/strings.json`: Update string keys/values referencing `'Item'` to `'Master_A'`.

### 2. Test Alignment
- **File**: `app_flutter/test/layout_test.dart`
- **Action**: Update test layout assertions and mock values from `'Item'` to `'Master_A'`.

---

## Part 5: Integration Test Path Adjustment for macOS Sandbox

To allow the GUI iteration stress tests to run successfully within the sandboxed macOS application environment:
1. **Benchmark Log Path**: Update the path of `benchmarkLogFile` in `app_flutter/integration_test/node_iteration_test.dart` to point to the active workspace (`/Users/perkunas/jail/digital-pipeline-repo/benchmark_results.jsonl`).
2. **macOS Sandbox Entitlements**: Update `app_flutter/macos/Runner/DebugProfile.entitlements` to permit read-write access to the `/jail/digital-pipeline-repo/` home-relative directory, allowing the application to write the benchmark results log file.

---

## Verification Plan

### Step 1: Database Rebuild & Verification
1. Run the database seed generator:
   ```bash
   (cd app_flutter && dart run lib/domain/database_initializer.dart)
   ```
2. Inspect the database tables using `sqlite3` to confirm the generated types and records match the template:
   ```bash
   sqlite3 app_flutter/assets/properties_db.db "SELECT * FROM type_definitions;"
   ```
   *(Expected: Master_A, Master_B, Master_C and Detail_A, Detail_B, Detail_C)*

### Step 2: Automated Tests
- Run `flutter test` and `flutter test integration_test/app_e2e_test.dart` to ensure zero regressions.

### Step 3: GUI / Performance & Memory Profiling Harness
- Run the GUI integration stress test harness to verify performance, theme/text scaling, and memory profile leakage constraints:
  ```bash
  (cd app_flutter && flutter test integration_test/node_iteration_test.dart)
  ```

### Step 4: Manual Visual Verification
- Boot the macOS application:
  ```bash
  (cd app_flutter && flutter run -d macos)
  ```
- Confirm the sidebar tree lists `Master_A`, `Master_B`, and `Master_C`.
- Confirm selecting each updates the properties and details views dynamically.
