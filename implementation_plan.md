# Remove All Mock Seeding and Layout Mocks

We will remove all hardcoded mock data and sample database generation logic from the baseline project workspace.

## Proposed Changes

### Configuration and Initializer

#### [MODIFY] [database_initializer.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/database_initializer.dart)
- Disable mock seeding by changing the default parameter of `DatabaseInitializer.create(..., bool seed = false)`.
- Make `_seed(db)` and `_addNodeToBatch` no-ops or remove mock items.

#### [MODIFY] [logical-layout.json](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/assets/logical-layout.json)
- Clear the hardcoded mock items in the `"hierarchy"` array, setting it to `[]` under `HierarchyTreeSelector`.

## Verification Plan

### Automated Tests
- Regenerate the SQLite database asset to apply the mock-free schema:
  ```bash
  dart run app_flutter/lib/domain/database_initializer.dart
  ```
- Run the Flutter tests to verify that the app initializes cleanly without mock data:
  ```bash
  flutter test app_flutter/
  ```
