# Implementation Plan: Domain Decoupling and Dynamic Layout/Validation

This plan details the changes required to decouple domain-specific code from the core framework and implement dynamic layouts/validation in scripts, React, and Flutter.

---

## Proposed Changes

### 1. Refactor YANG Compiler (`scripts/compile_yang.py`)
- **Target File**: `scripts/compile_yang.py`
- **Action**: Modify `build_lui_json` to load `codebase_rules.json` or `.pipeline/logical-ui/codebase_rules.json`. Retrieve `"layout_rules" -> "details_tabs"`. If defined, use it to populate the `TabbedContainer` children. If not defined, fallback to a single generic properties `TableView` tab:
  ```python
  {
    "type": "TableView",
    "id": "properties_table",
    "props": { "title": "Properties" }
  }
  ```

### 2. Refactor Validation Libraries
- **Target File**: `app_flutter/lib/domain/validation.dart`
  - **Action**: Remove hardcoded validators (`validateLoadSpec`, `validatePostalAddress`, `validateTemporalContext`, `validatePlaceType`, `hasSlotOverlap`, `validateUnitAllocation`). Keep frame validation logic (`validateReferenceFrame`, `sanitizeFrameName`, `ReferenceFrameValidation`).
  - **Action**: Implement `validateFields(Map<String, dynamic> input, List<FieldDescriptor> descriptors)` to evaluate constraints (`isRequired`/`required`, `minValue`/`maxValue`, `pattern`, `options`/`enumOptions`).
- **Target File**: `web_react/src/domain/validation.ts`
  - **Action**: Remove hardcoded validators and types. Replicate the generic `validateFields(input, descriptors)` logic in TypeScript.

### 3. Refactor React Property Grid (`web_react/src/components/property-grid.tsx`)
- **Target File**: `web_react/src/components/property-grid.tsx`
- **Action**: Remove hardcoded imports of validators. Import `validateFields` from validation library. Import `logicalLayout` from `.pipeline/logical-ui/logical-layout.json`.
- **Action**: Dynamically render inputs by looping over `logicalLayout.attributes` (falling back to a default representation if empty).
- **Action**: Group controls by `sectionGroup`. Generate inputs of type textbox, number, checkbox, and dropdown based on attribute specifications. Evaluate validation using `validateFields`.

### 4. Refactor Baseline Conformance Gate (`scripts/verify_downstream_baseline.py`)
- **Target File**: `scripts/verify_downstream_baseline.py`
- **Action**: Clear the default fallback list of `MANDATED_CLASSES` to `[]`.

### 5. Update Guide (`docs/operations/yang-compiler-guide.md`)
- **Target File**: `docs/operations/yang-compiler-guide.md`
- **Action**: Clarify Section 4.2 to indicate that property mappings are dynamic, and label network topology terms as examples.

### 6. Update Test Suites
- **Target File**: `app_flutter/test/domain/validation_test.dart`
  - **Action**: Add unit tests that pass mock `FieldDescriptor`s to `validateFields` to assert boundaries, types, required flags, and regex pattern constraints.
- **Target File**: `web_react/src/components/layout.test.tsx`
  - **Action**: Rewrite unit tests to test `validateFields` using mock descriptors instead of old hardcoded validators. Update tests to match the dynamic rendering of the Property Grid.

---

## Verification Plan

### Step 1: Python/YANG Verification
- Run compiler execution check:
  `python3 scripts/compile_yang.py -i example-system.yang -o test-layout.json` (if example-system.yang exists or mock compilation)
- Verify `verify_downstream_baseline.py` passes with empty mandated classes fallback.

### Step 2: React Verification
- Install dependencies: `npm install` in `web_react`.
- Build application: `npm run build` in `web_react`.
- Run tests: `npm test` in `web_react`.

### Step 3: Flutter Verification
- Resolve dependencies: `flutter pub get` in `app_flutter`.
- Run analyzer: `flutter analyze` in `app_flutter`.
- Run test suite: `flutter test` in `app_flutter`.

### Step 4: Commit and Push
- Commit all changes on `feat/domain-decoupling` and push to origin.
- Confirm `git diff origin/feat/domain-decoupling` is empty.
