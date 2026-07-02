# Implementation Plan: Defect #12 Remediation (Natural Sorting & Multi-Level Seeding)

This plan details the changes to apply natural sorting to the sidebar tree nodes and properties grid fields, and to expand database seeding to generate detail instances for all hierarchical levels.

---

## Proposed Changes

### 1. Seeding Adjustment
- **File**: `app_flutter/lib/domain/database_initializer.dart`
- **Action**:
  - Remove the `if (isRoot)` guard to seed detail instances for all levels of tree nodes (Roots, Children, and Grandchildren).
  - To optimize database asset file size, set the number of detail instances per table to **5** (totaling 15 detail rows per tree node), keeping the gzipped asset package size under 15MB.

---

### 2. Natural Sorting for Tree Nodes
- **File**: `app_flutter/lib/features/tree/view_models/tree_view_model.dart`
- **Action**:
  - Implement a natural alphanumeric sorting comparator for sorting tree nodes:
    ```dart
    int naturalCompare(String a, String b) {
       // Compares strings containing numbers naturally, e.g., "Master_2" < "Master_10"
    }
    ```
  - Sort the root nodes and children lists recursively before notifying listeners.

---

### 3. Natural Sorting for Properties Grid Fields
- **File**: `app_flutter/lib/features/properties/property_grid.dart`
- **Action**:
  - Ensure that fields are rendered in their natural numerical sorting order (`field_1` through `field_50`) rather than simple lexicographical string sorting.

---

## Verification Plan

### Step 1: Run the Profiler Audit
1. Execute the profiling audit runner:
   ```bash
   python3 scripts/run_profile_audit.py
   ```
2. Verify the audit succeeds and outputs:
   - **Average Frame Build Time**: under **16.6ms** (Target met).
   - **Memory Leaks**: `False` (No leaks).

### Step 2: Automated Tests
- Run `flutter test` to ensure zero regressions across widget and unit test suites.
