# Implementation Plan - Issue #66 Widget Test SQLite FFI Refactor

This plan details the refactoring of `app_flutter/test/widget_test.dart` to replace the mock repository with a real SQLite FFI in-memory database instance.

## Proposed Changes

### 1. `app_flutter/test/widget_test.dart`
- Remove the `MockRepository` class and its usages.
- Import `package:sqflite_common_ffi/sqflite_ffi.dart` and `package:app_flutter/domain/repository.dart`.
- In `main()`, initialize SQLite FFI using `sqfliteFfiInit()`.
- Within the widget test, open an in-memory database using `databaseFactoryFfi.openDatabase(inMemoryDatabasePath)`.
- Execute the schema SQL to create the `properties` table: `CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);`.
- Instantiate `SqliteRepositoryAdapter` with the opened database and inject it into `MyApp`.
- Close the database connection cleanly using `db.close()`.

## Verification Plan

### Automated Verification Steps
1. Run `flutter analyze` inside `app_flutter/` to verify zero static analysis warnings.
2. Run `flutter test` inside `app_flutter/` to verify all tests pass with zero regressions.
