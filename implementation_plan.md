# Implementation Plan: Seeding 1,000 Master Nodes with 50 Properties & 50 Table Rows

This plan details the changes to expand the SQLite database seeding to a high-density, real-world stress dataset: 1,000 Master Nodes, each with 50 properties, and 50 rows in each detail table (totaling 150,000 detail instances).

---

## Proposed Changes

### 1. Seeding Logic Refactor
- **File**: `app_flutter/lib/domain/database_initializer.dart`
- **Action**:
  - Replace master nodes count with 1,000 master nodes (`Master_1` to `Master_1000`).
  - Update `type_attributes` count to generate 50 fields (`field_1` to `field_50`) for all types (masters and details).
  - Update properties seeding to write 50 properties inside the `data_json` map for each master node.
  - Update `instances` seeding to insert 50 detail instances per detail type (`Detail_A`, `Detail_B`, `Detail_C`) for each of the 1,000 master nodes (totaling 150,000 instance rows).

---

### 2. Table Column Constraint Fix (Defect Remediation)
- **File**: `app_flutter/lib/features/tables/table_view_widget.dart`
- **Action**:
  - Enforce a minimum column width of `120.0` pixels using `math.max` to prevent cumulative column spacing from producing negative width constraints under high column counts (such as 50 columns):
    ```dart
    final colWidth = math.max(120.0, (constraints.maxWidth - 2 * widget.horizontalMargin - spacingWidth) / colCount);
    ```

---

### 3. Application Default Shell State
- **Files**:
  - `app_flutter/lib/app/app.dart`: Set default active view `_activeView = 'Master_1';`.
  - `app_flutter/assets/strings.json`: Update `"fallback.typeName"` to `'Master_1'`, and add fallback field labels for `field_1` through `field_50`.
  - `app_flutter/lib/features/tree/tree_defaults.dart`: Update default fallback tree nodes to `Master_1`, `Master_2`, and `Master_3`.

---

### 4. Test Alignment
- **Files**:
  - `app_flutter/integration_test/app_e2e_test.dart`
  - `app_flutter/test/layout_test.dart`
  - `app_flutter/test/widget_test.dart`
- **Action**: Update assertions, loops, and mock expectations to handle the expanded type names (`Master_1`) and check rendering across the 50 properties.

---

## Verification Plan

### Step 1: Database Rebuild
1. Run the database seed script to compile the new high-density database asset:
   ```bash
   (cd app_flutter && dart run lib/domain/database_initializer.dart)
   ```
2. Verify table size using SQLite query commands:
   ```bash
   sqlite3 app_flutter/assets/properties_db.db "SELECT count(*) FROM type_definitions;"
   sqlite3 app_flutter/assets/properties_db.db "SELECT count(*) FROM type_attributes;"
   sqlite3 app_flutter/assets/properties_db.db "SELECT count(*) FROM instances;"
   ```
   *(Expected: 1,003 type definitions, 50,150 attributes, and 150,000 detail instances)*

### Step 2: Automated Tests
- Run `flutter test` and `flutter test integration_test/app_e2e_test.dart` to verify zero regressions.

### Step 3: GUI / Performance & Memory Profiling Harness
- Run the GUI iteration stress test to verify rendering speeds and memory allocation safety under the high-density layout:
  ```bash
  (cd app_flutter && flutter test integration_test/node_iteration_test.dart)
  ```
