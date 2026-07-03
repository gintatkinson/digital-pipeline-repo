# Implementation Plan: Fluid Multi-Column Responsive Property Grid (1 to 4 Columns)

This plan details the changes to refactor the properties grid rendering layout from a hardcoded 2-column model to a fluid, multi-column responsive model (supporting 1 to 4 columns) depending on the available viewport width, following LayoutBuilder performance best practices.

---

## Proposed Changes

### 1. Multi-Column Wrap Layout & Cache Guard (PropertyGrid)
- **File**: `app_flutter/lib/features/properties/property_grid.dart`
- **Action**:
  - Implement a fluid column count calculation inside the `LayoutBuilder` of `PropertyGrid`:
    ```dart
    final double targetWidth = 350.0; // Optimal card width
    final int columnCount = (constraints.maxWidth / targetWidth).floor().clamp(1, 4);
    ```
  - Refactor the grid render structure to use a `Wrap` widget with dynamic width assignments per section card rather than hardcoding a `Row` of 2 widgets:
    ```dart
    final double cardWidth = (constraints.maxWidth - (columnCount - 1) * widget.gapSize) / columnCount;
    ```
  - Optimize: Add a check to only rebuild the field group widgets when the `columnCount` changes, preventing layout jitter and GC overhead during fine window resizes.

---

### 2. Test Alignment
- **Files**:
  - `app_flutter/test/layout_test.dart`
- **Action**: Update responsive layout checks to align with the new Wrap and dynamic column structure.

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
