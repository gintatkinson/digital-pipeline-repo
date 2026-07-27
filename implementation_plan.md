# Implementation Plan: Clean Architecture Domain Layer Refactoring

## Overview
Refactor `app_flutter` to comply with Clean Architecture by moving data and presentation concerns out of the domain layer and fixing all import paths.

## Steps
1. **Write `refactor_imports.py` in `scratch/`**:
   The script will:
   - Move `app_flutter/lib/domain/cesium_3d` to `app_flutter/lib/features/map_viewport/cesium_3d`
   - Move `app_flutter/lib/domain/data_sources` to `app_flutter/lib/data/data_sources`
   - Move `app_flutter/lib/domain/database_initializer.dart` to `app_flutter/lib/data/database_initializer.dart`
   - Move `app_flutter/lib/domain/domain_seed_strategy.dart` to `app_flutter/lib/data/seeds/domain_seed_strategy.dart`
   - Move `app_flutter/lib/domain/repository_resolver.dart` to `app_flutter/lib/core/di/repository_resolver.dart`
   - Walk all `.dart` files in `app_flutter/lib`, `app_flutter/test`, and `app_flutter/integration_test` recursively.
   - Replace old absolute package imports with new paths.
   - Replace old `cesium_3d` package imports with new paths.
   - Fix broken relative imports within the moved files so they resolve to the domain types properly (e.g. converting `import 'type_descriptor.dart';` to `import 'package:app_flutter/domain/type_descriptor.dart';`).

2. **Run the Refactoring Script**:
   Execute `python scratch/refactor_imports.py`.

3. **Verify Refactoring**:
   - Run `cd app_flutter && flutter analyze && flutter test`.
   - Run `./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`.

4. **Commit and Push**:
   - `git add .`
   - `git commit -m "refactor: clean domain layer leakage by moving presentation and data concerns"`
   - `git push origin main`
   - Verify `git diff origin/main` is empty.
