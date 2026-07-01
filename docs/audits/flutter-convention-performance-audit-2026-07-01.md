# Flutter Convention & Performance Audit — 2026-07-01

Audit of recently created/modified files in `app_flutter/lib/` for Flutter
convention violations and performance anti-patterns.

## File: `action_panel.dart` (NEW)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 162–216 | Controller not disposed | `TextEditingController` instances created inside `showDialog` builder closure; on dialog rebuild (orientation change) old controllers leak until dialog closes | Medium |

## File: `state_indicator.dart` (NEW) — CLEAN

## File: `action_descriptor.dart` (NEW) — CLEAN (domain model)

## File: `column_model.dart` (NEW) — CLEAN (domain model)

## File: `cell_renderer.dart` (NEW)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 90 | Missing const constructor | `BooleanRenderer` has no `const` constructor, preventing const instantiation | Low |
| 2 | 102 | Missing const constructor | `ReferenceRenderer` has no `const` constructor | Low |

## File: `layout.dart` (MODIFIED)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 431–432 | FutureBuilder new Future every rebuild | `_buildChildWidget` creates `_dataSource?.getActions(_currentView)` inline in `FutureBuilder.future`; on every rebuild a new async call starts | **High** |
| 2 | 155–170, 245 | Expensive sync I/O in build | `_loadJsonOnce` does sync file I/O (`file.existsSync()`, `readAsStringSync()`) on UI thread during first build | Medium |
| 3 | 42–47 | Missing const constructor | `Layout` StatefulWidget constructor not const | Medium |
| 4 | 127, 133, 191 | Overly broad setState | `_onPropertiesViewModelChanged`, `_onTreeViewModelChanged`, worker callback all call `setState(() {})` with empty body, rebuilding entire Layout tree | Medium |
| 5 | 75 | Unnecessary GlobalKey | `_propertyGridKey` is GlobalKey but never accessed via `.currentState` or `.currentWidget`; ValueKey suffices | Low |

## File: `component_factory.dart` (MODIFIED) — CLEAN

## File: `property_grid.dart` (MODIFIED)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 271, 203–210 | O(n) isDirty scan per keystroke | `_notifyDirtyIfChanged` listener on every TextEditingController; on every keystroke `isDirty` iterates all fields O(n). For 50+ fields causes input lag | Medium |
| 2 | 1096, 631 | Expensive JSON serialization per build | `_buildCommittedStatePanel` runs `JsonEncoder.withIndent(2).convert(committedData)` on every build; on every keystroke via dirty-state listener | Medium |
| 3 | 523–540 | New formatter instance per build | `_resolveInputFormatters` creates new `UpperCaseTextFormatter()` on every build; should be const singleton | Low |

## File: `properties_view_model.dart` (MODIFIED) — CLEAN

## File: `table_view_widget.dart` (MODIFIED)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 69, 74 | ScrollController leaked | Field-initialized ScrollController (line 69) immediately overwritten in `initState` (line 74); first instance never disposed | Medium |
| 2 | 114–122 | Sort recomputed every build | Full row sort O(n log n) runs on every `build()` even when sort state unchanged | Medium |
| 3 | 436 | O(n*m) indexWhere in DataRow | `allHeaders.indexWhere((h) => h.key == columnModels[i].key)` per cell per row; Map lookup would be O(1) | Low |

## File: `tables_view_model.dart` (MODIFIED) — CLEAN

## File: `topology_map.dart` (MODIFIED)

| # | Line | Type | Description | Severity |
|---|------|------|-------------|----------|
| 1 | 441–466 | minTime/maxTime iterates all nodes 60fps | Getters called from `_onTick` (60 Hz), `setPlayhead`, and `build()`; every call O(n) over all nodes. Should cache and recompute only on data change | **High** |
| 2 | 692–704 | TopologyPainterColors recreated every build | New colors object every build; `shouldRepaint` compares by identity so canvas repaints on every widget build even when nothing changed | Medium |
| 3 | 546 | _buildPlaybackPanel not const | Called inside `build()` recreating widget subtree every rebuild; extracting as const widget would allow Element reuse | Low |

## File: `topographical_view.dart` (MODIFIED) — CLEAN

## Summary

| Severity | Count | Key Files |
|----------|-------|-----------|
| **High** | 2 | `layout.dart` (FutureBuilder), `topology_map.dart` (60fps O(n)) |
| **Medium** | 9 | `property_grid.dart` (2), `table_view_widget.dart` (2), `layout.dart` (3), `topology_map.dart` (1), `action_panel.dart` (1) |
| **Low** | 6 | `cell_renderer.dart` (2), `layout.dart` (1), `property_grid.dart` (1), `table_view_widget.dart` (1), `topology_map.dart` (1) |
