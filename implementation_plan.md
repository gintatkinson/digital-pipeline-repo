# Implementation Plan - Domain Decontamination and Codebase Refactoring

This plan outlines the specific steps to execute the decontamination and refactoring of the repository to completely purge all standard-specific geodetic and hardware domain pollution.

---

## 1. Proposed Changes

### 1.1 Documentation Cleanup
- **[DELETE]** [`docs/designs/feat-g1-g12-solution-definition.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/designs/feat-g1-g12-solution-definition.md)
- **[DELETE]** [`docs/decisions/audits/astrodynamics_geodesy_critique.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/audits/astrodynamics_geodesy_critique.md)
- **[DELETE]** [`docs/decisions/audits/communications_rf_laser_critique.md`](file:///Users/perkunas/jail/digital-pipeline-repo/docs/decisions/audits/communications_rf_laser_critique.md)
- **[DELETE]** [`task.md`](file:///Users/perkunas/jail/digital-pipeline-repo/task.md) (repository root)
- **[DELETE]** [`walkthrough.md`](file:///Users/perkunas/jail/digital-pipeline-repo/walkthrough.md) (repository root)

---

### 1.2 Flutter Codebase Refactoring

#### [MODIFY] [validation.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/domain/validation.dart)
- Remove `ReferenceFrameValidation` class.
- Remove `validateReferenceFrame` function.
- Remove `sanitizeFrameName` function.
- Ensure only `validateFields` remains.

#### [MODIFY] [validation_test.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/validation_test.dart)
- Remove the `sanitizeFrameName` test group.
- Remove the `validateReferenceFrame` test group.

#### [MODIFY] [firebase_data_source.dart](file:///Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/data/data_sources/firebase_data_source.dart)
- Refactor `fetchTopologyData` to resolve coordinates dynamically using search helpers `_findPathToKey` and `_resolveCoordinateValue` (identical to `sqlite_data_source.dart`), instead of hardcoding `ietfGeoLocation` keys.

---

### 1.3 React Codebase Refactoring

#### [MODIFY] [types.ts](file:///Users/perkunas/jail/digital-pipeline-repo/web_react/src/types.ts)
- Remove geodetic/hardware interfaces: `Velocity`, `TemporalContext`, `PhysicalAddress`, `PhysicalStructuralSubsystem`, `LocationType`, `LocationHierarchy`, `RackLocation`, `Rack`, `ContainedChassis`, `ChassisContainmentSubsystem`.

#### [MODIFY] [property-grid.tsx](file:///Users/perkunas/jail/digital-pipeline-repo/web_react/src/components/property-grid.tsx)
- Remove geodetic/structural keys from `defaultShowcase`.
- Remove geodetic/structural items from `fallbackAttributes`.

---

## 2. Verification Plan

### Automated Tests
- Run `flutter test test/domain/validation_test.dart` to verify that the remaining generic validation tests pass.
- Run `flutter analyze` inside `app_flutter/` to ensure no compile-time/static analysis errors.
- Run React tests: `npm run test` or `vitest run` inside `web_react/` to verify React compilation.

### Manual Verification
- Check that all deleted files are removed from git tracking.
- Run `reconcile_backlog.py` to reconcile backlog.
- Verify that `git status` shows no untracked or dirty root files.
