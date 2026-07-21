# Implementation Plan - Issue #64 Tables Loading Spinner Stuck Regression Test

This plan outlines the steps to audit the tables view model and add a regression unit test to verify that `loadForNode` resets `_loading` to `false` and notifies listeners when the type descriptor is null.

## Proposed Changes

### Phase 1: Audit & Codebase Modifications

1. **Audit VM behavior**:
   - Inspect `app_flutter/lib/features/tables/view_models/tables_view_model.dart` at L135-141.
   - Confirm that if `typeFor` returns `null`, the view model sets `_loading` to `false` and calls `notifyListeners()`.

2. **Add Regression Unit Test**:
   - **File**: `app_flutter/test/features/tables/view_models/tables_view_model_test.dart`
   - **Location**: Add a new test group `TablesViewModel loadForNode error handling` at the end of the `main()` function block.
   - **Test Details**:
     ```dart
     group('TablesViewModel loadForNode error handling', () {
       late _MockDataSource dataSource;
       late TablesViewModel viewModel;

       setUp(() {
         dataSource = _MockDataSource();
         viewModel = TablesViewModel(dataSource, 'test');
       });

       test('loadForNode resets loading to false and notifies listeners when type descriptor is null', () async {
         dataSource.onTypeFor = (typeName) async => null;

         bool notified = false;
         viewModel.addListener(() {
           if (!viewModel.loading) {
             notified = true;
           }
         });

         await viewModel.loadForNode('unknown-node');

         expect(viewModel.loading, isFalse);
         expect(notified, isTrue);
       });
     });
     ```

### Phase 2: Verification & Test Execution

1. Run the specific unit test suite:
   ```bash
   flutter test test/features/tables/view_models/tables_view_model_test.dart
   ```
2. Verify that all 11 tests (including the new regression test) pass successfully.

### Phase 3: Git Operations & Synchronization

1. Stage the modified test file:
   ```bash
   git add test/features/tables/view_models/tables_view_model_test.dart
   ```
2. Commit with the message:
   `test: add regression test for stuck tables loading spinner on null type descriptor`
3. Push the changes to the remote branch `feat/58-63-linter-fixes`:
   ```bash
   git push origin feat/58-63-linter-fixes
   ```
4. Verify that `git diff origin/feat/58-63-linter-fixes` is empty.
