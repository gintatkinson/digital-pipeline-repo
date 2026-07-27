# Implementation Plan - Refactor ColumnModel to Feature Layer

This plan migrates `ColumnModel` from the domain layer to the tables feature layer inside `app_flutter` to restore proper architectural encapsulation and separation of presentation concerns.

## 1. Proposed Changes

### [NEW] [column_model.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/tables/models/column_model.dart)
Move `app_flutter/lib/domain/column_model.dart` to `app_flutter/lib/features/tables/models/column_model.dart`.
Ensure the package import `import 'type_descriptor.dart';` is adjusted if relative path resolves differently.
*   Note: Since `type_descriptor.dart` was in `lib/domain/`, the new import in `column_model.dart` should be `import '../../../domain/type_descriptor.dart';` (or package-relative: `import 'package:app_flutter/domain/type_descriptor.dart';`). We will use package-relative for cleanliness.

### [NEW] [column_model_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/features/tables/models/column_model_test.dart)
Move `app_flutter/test/domain/column_model_test.dart` to `app_flutter/test/features/tables/models/column_model_test.dart`.
Update imports to reference `package:app_flutter/features/tables/models/column_model.dart`.

### [DELETE] [column_model.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/column_model.dart)
Delete the old file from the domain layer.

### [DELETE] [column_model_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/column_model_test.dart)
Delete the old test file.

### [MODIFY] [table_view_widget.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/tables/table_view_widget.dart)
Update import path from `package:app_flutter/domain/column_model.dart` to `package:app_flutter/features/tables/models/column_model.dart`.

### [MODIFY] [tables_view_model.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/tables/view_models/tables_view_model.dart)
Update import path to `package:app_flutter/features/tables/models/column_model.dart`.

### [MODIFY] [table_view_widget_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/features/tables/table_view_widget_test.dart)
Update import path to `package:app_flutter/features/tables/models/column_model.dart`.

### [MODIFY] [tables_view_model_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/features/tables/view_models/tables_view_model_test.dart)
Update import path to `package:app_flutter/features/tables/models/column_model.dart`.

## 2. Verification Plan
1.  **Linter check**: Run `cd app_flutter && flutter analyze` to ensure zero compilation or import resolution errors.
2.  **Unit & Widget tests**: Run `cd app_flutter && flutter test` to ensure all 273 tests pass successfully.
3.  **Spec linter check**: Run `./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only` to ensure no specifications are impacted.

## 3. Finalization
1. Commit changes: `git commit -m "refactor: move ColumnModel to tables feature layer in app_flutter"`
2. Push to `origin/main`
3. Verify `git diff origin/main` is empty.
