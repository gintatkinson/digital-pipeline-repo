# Implementation Plan

## Phase 1: Skill Reading
1. Read `.agents/skills/debug-protocol/SKILL.md`.
2. Read `.agents/skills/performance-profiling-test-automation/SKILL.md`.

## Phase 2: Codebase Fixes
1. **Database Seeding format update**:
   - File: `app_flutter/lib/domain/database_initializer.dart`
   - Changes: In `_seed`, change `'type_name': 'Links'` to `'type_name': 'interface'`, and change `'data_json': jsonEncode({'target': to})` to `'data_json': jsonEncode({'description': 'link to node $to'})`.
   - Action: Run `flutter test lib/domain/database_initializer.dart` to generate DB files.
2. **Double Earth-Radius Projection Correction**:
   - File: `app_flutter/lib/features/topology/scene_3d_viewport.dart`
   - Changes: Change `heightMeters` to `ampElev` at line 252.
   - File: `app_flutter/lib/features/topology/scene_3d_viewport_classes.dart`
   - Changes: Lines 438-456: remove `Ellipsoid.wgs84EquatorialRadius +` additions.
3. **Database Overwrite & Drift Fix**:
   - File: `app_flutter/lib/domain/repository_resolver.dart`
   - Changes: Force overwrite database in ApplicationSupport if size or record schema does not match the gzipped assets bundle.
4. **Force Test Database Injection & Assertions**:
   - File: `app_flutter/integration_test/viewport_perf_test.dart`
   - Changes: Inject test database `DataSource` provider. Add assertions for `nodes.length > 800` and `links.length > 1000`.
5. **Entitlements Outbound Access**:
   - Files: `app_flutter/macos/Runner/DebugProfile.entitlements` and `app_flutter/macos/Runner/Release.entitlements`
   - Changes: Add `<key>com.apple.security.network.client</key><true/>`.
6. **Stuck Table Spinner Debug**:
   - File: `app_flutter/lib/features/tables/view_models/tables_view_model.dart`
   - Changes: Trace and resolve deadlock/uncompleted Future/infinite stream.

## Phase 3: Workspace Contamination Scan
1. Run scan for `3dgs`, `phoenix`, `ion`, or `dgph` inside `/Users/perkunas/jail/digital-pipeline-repo`.
2. Write matches to `/Users/perkunas/.gemini/antigravity/brain/35945883-18ea-4018-81b3-27aba96f2102/contamination_report.md`.
3. Stop and report back before making contamination changes.

## Phase 4: Automated Verification & Packaging
1. Run `python3 scripts/verify_downstream_baseline.py`.
2. Run `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/viewport_perf_test.dart -d macos`.

## Phase 5: Backlog & Sync
1. Run `python3 .agents/skills/spec-orchestrator/scripts/reconcile_backlog.py`.
2. Stage, commit, and push.
