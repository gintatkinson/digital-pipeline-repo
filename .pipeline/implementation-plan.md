# Clean Flutter Template — Implementation Plan

## Starting Point

Branch: `clean-governance` (governance only, no app_flutter)
Base: `app_flutter/` created via `flutter create --org com.pipeline --project-name pipeline_app app_flutter`

## Architecture

The app is a domain-agnostic, runtime-discovered management console. The sidebar tree displays a flat list of master instance nodes. Selecting a node populates a property grid (from type attributes) and tabbed tables (from type relations). Zero hardcoded domain knowledge. All naming follows set-theory conventions: Type0..TypeN, attr_01..attr_M, Section_01..Section_K.

## Contracts (Level 0 — write first)

### domain/type_descriptor.dart

```dart
enum FieldType { string, int_, double_, enum_, date, bool_ }

class FieldDescriptor {
  final String key;
  final String label;
  final FieldType type;
  final String? sectionLabel;
  final int sectionOrder;
  final bool required;
  final num? minValue;
  final num? maxValue;
  final String? pattern;
  final List<String>? enumOptions;
  final List<String>? enumDisplayNames;
  final dynamic defaultValue;
  final List<String>? inputFormatters;
}

class TypeRelationDescriptor {
  final String relationName;
  final String targetTypeName;
  final String displayLabel;
}

class TypeDescriptor {
  final String typeName;
  final String displayName;
  final String iconName;
  final List<FieldDescriptor> fields;
  final List<TypeRelationDescriptor> childTypes;
  final List<TypeRelationDescriptor> parentTypes;
}

class InstanceDescriptor {
  final String nodeId;
  final String typeName;
  final String displayLabel;
}
```

### domain/data_source.dart

```dart
abstract class DataSource {
  String get name;
  Future<List<TypeDescriptor>> discoverTypes();
  Future<TypeDescriptor?> typeFor(String typeName);
  Future<List<InstanceDescriptor>> discoverInstances();
  Future<Map<String, dynamic>?> fetchProperties(String nodeId);
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchChildren(String nodeId, String relationName);
}
```

## Files (19 total)

```
Level 1 — Backend + Core (4 parallel)
  domain/sqlite_data_source.dart   SQLite: 5 tables, all DataSource methods, exposes db getter
  domain/icon_mapper.dart          IconName → IconData (8 generic icons)
  core/theme_controller.dart       ThemeMode, ThemeData, SharedPreferences
  core/text_scaler.dart            Scale 0.7–1.5, file persistence

Level 2 — Seed (1)
  domain/seed_system_data.dart     SeedConfig (6 required: typeCount, masterCount, 
                                   attributesPerType, sectionsPerType, relationCountPerType, 
                                   rowsPerRelation) + seedSystemData(db, config)

Level 3 — View Models (3 parallel)
  features/tree/tree_view_model.dart     Flat list from discoverInstances(), selection
  features/detail/detail_view_model.dart  typeFor() + fetchProperties() + fetchChildren()
  features/settings/settings_panel.dart   Theme toggle + text scale slider widget

Level 4 — Widgets (4 parallel)
  features/tree/tree_sidebar.dart         ListView of instances, selection highlight
  features/detail/property_grid.dart       Form per FieldDescriptor, grouped sections
  features/detail/table_panel.dart         TabBar + DataTable from fetchChildren()
  features/layout/breadcrumbs.dart         Navigation path

Level 5 — Wiring (1)
  app.dart                                Row: sidebar | detail panel, providers

Level 6 — Entry (1)
  main.dart                               SQLite init, seed, run PipelineApp

Level 7 — Verification (5)
  test/seed_test.dart                     COUNT queries
  test/widget_smoke_test.dart             Renders without crash  
  flutter analyze                         Zero errors
  contamination audit                     Grep all .dart files for domain terms
  flutter run -d macos                    App launches with seeded data
```

## SQLite Tables (5)

```
type_definition  (type_name TEXT PK, display_name TEXT, icon_name TEXT)
type_attribute   (id INTEGER PK AUTOINCREMENT, type_name TEXT FK, attr_key TEXT, label TEXT,
                  attr_type TEXT, section_label TEXT, section_order INTEGER, is_required INTEGER,
                  min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT,
                  enum_display_names TEXT, default_value TEXT, input_formatters TEXT,
                  UNIQUE(type_name, attr_key))
type_relation    (id INTEGER PK AUTOINCREMENT, parent_type_name TEXT FK,
                  relation_name TEXT, child_type_name TEXT FK, child_label TEXT,
                  UNIQUE(parent_type_name, child_type_name))
instance         (node_id TEXT PK, data_json TEXT)
child_entry      (id TEXT PK, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)
```

## Naming Conventions (all formula-derived)

- Types: `Type$ti` where ti=0..typeCount-1
- Node IDs: `Type$ti-${count.padLeft(3,'0')}` 
- Attributes: `attr_${(ai+1).toString().padLeft(2,'0')}`
- Labels: `String Field $padded`, `Integer Field $padded`, etc.
- Sections: `Section_${(si+1).toString().padLeft(2,'0')}`
- Relations: relation_name=`relates_to_Type$targetIndex`, child_label=`Type $targetIndex Records`
- Icons: data_object, folder, insert_drive_file, label, settings, storage, cloud, dns

## Contamination Gate

After every file write, grep for domain terms:
```
grep -i "alarm\|event\|device\|sensor\|critical\|warning\|severity\|active\|standby\|error\|status\|source\|target" file.dart
```
Any match from a hardcoded string literal = reject. Formula-derived variable names (targetIndex, eventIndex) are false positives and pass.

## Verification

Seed with: `SeedConfig(typeCount: 8, masterCount: 100, attributesPerType: 30, sectionsPerType: 5, relationCountPerType: 3, rowsPerRelation: 10)`

Expected counts:
- type_definition: 8
- type_attribute: 240
- type_relation: 24
- instance: 100
- child_entry: 2400

## Dependencies

pubspec.yaml additions:
- sqflite_common_ffi
- path_provider
- path
- shared_preferences
