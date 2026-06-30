# Runtime Metadata Architecture Blueprint (v2.1)

> Goal: Make the Flutter app fully metadata-driven — the client knows **nothing** at compile time. Every object type, field, icon, validation rule, section label, and relationship is discovered at runtime from the connected data source.

**Core realization**: A static `logical-layout.json` with more fields is just hardcoding in a different format. The app must discover all schemas at runtime because:
- Multiple domains are supported (telco, air traffic control, fleet management)
- Data sources are swappable at runtime (SQLite ↔ Firebase ↔ gRPC/Protobuf ↔ REST)
- For gRPC/Protobuf, the `.proto` file **is** the metadata — no separate schema file needed

---

## 1. Core Abstraction: TypeDescriptor

Each data source returns one `TypeDescriptor` per object type. The client renders whatever this tells it — there is zero hardcoded knowledge.

```dart
/// Describes one object type known to the connected data source.
/// The client uses this to render trees, property forms, tables, and graphs.
abstract class TypeDescriptor {
  String get typeName;          // "Chassis", "Sensor", "FlightRoute"
  String get displayName;       // "Chassis", "Sensor", "Flight Route"
  IconData get icon;            // Icon resolved at runtime
  List<FieldDescriptor> get fields;
  List<TypeRelationDescriptor> get childTypes;   // tree hierarchy
  List<TypeRelationDescriptor> get parentTypes;   // reverse hierarchy
}

class FieldDescriptor {
  final String key;
  final String label;
  final FieldType type;             // string, int, double, enum, date, bool
  final String? sectionLabel;       // UI grouping: "Power", "Location"
  final int sectionOrder;
  final bool required;
  final num? minValue;
  final num? maxValue;
  final String? pattern;            // regex validation
  final List<String>? enumOptions;
  final List<String>? enumDisplayNames;
  final dynamic defaultValue;
  final List<InputFormatterDescriptor>? inputFormatters;
  final String? refType;            // foreign-key: type name this field references
}

class TypeRelationDescriptor {
  final String relationName;        // "contains", "connected_to", "depends_on"
  final String targetTypeName;      // "Sensor", "Router", "RadarUnit"
  final String displayLabel;        // "Sensors", "Connected Routers"
}

enum FieldType { string, int, double, enum_, date, bool }

class InputFormatterDescriptor {
  final String formatter;           // "uppercase", "maxLength", "prefix"
  final dynamic value;
}
```

### What TypeDescriptor eliminates

| Current hardcoding | TypeDescriptor replacement |
|---|---|
| `switch(node.id)` for icons in `tree_node_widget.dart:26-48` | `typeDescriptor.icon` |
| `_sectionLocation` / `_sectionAlternate` if/else in `property_grid.dart:45-46,301-303` | `fieldDescriptor.sectionLabel` + `sectionOrder` |
| `defaultValidator` in `property_defaults.dart:38-89` | `fieldDescriptor.minValue` / `maxValue` / `pattern` / `required` |
| `defaultShouldPair` in `property_defaults.dart:31-35` | Not needed — sections group fields; pairing is a UI concern the generic renderer handles by adjacency |
| `defaultFallbackInitialValues` in `property_defaults.dart:7-18` | `fieldDescriptor.defaultValue` |
| `defaultOptionDisplayNames` in `property_defaults.dart:21-28` | `fieldDescriptor.enumOptions` + `enumDisplayNames` |
| `_keyCountryCode` formatter in `property_grid.dart:519-524` | `fieldDescriptor.inputFormatters` |
| `_typeDouble` / `_typeInt` / `_typeEnum` in `property_grid.dart:48-50` | `fieldDescriptor.type` directly |

---

## 2. DataSource Abstraction

```dart
/// Abstract interface for a data source that provides type metadata
/// and CRUD operations. Implementations are swappable at runtime.
abstract class DataSource {
  String get name;                              // "sqlite", "firebase", "grpc", "rest"

  /// Discover every object type this data source knows about.
  Future<List<TypeDescriptor>> discoverTypes();

  /// Get the TypeDescriptor for a single type.
  Future<TypeDescriptor> typeFor(String typeName);

  /// Fetch property values for one instance.
  Future<Map<String, dynamic>> fetchProperties(
    String typeName, String instanceId);

  /// Fetch child instances linked via [relationName].
  Future<List<Map<String, dynamic>>> fetchChildren(
    String typeName, String parentId, String relationName);

  /// Persist property values.
  Future<void> saveProperties(
    String typeName, String instanceId, Map<String, dynamic> data);

  /// Reactive stream of property changes.
  Stream<Map<String, dynamic>> watchProperties(
    String typeName, String instanceId);
}
```

### Relationship to existing AbstractRepository

The current `AbstractRepository` (`app_flutter/lib/domain/repository.dart`) operates on opaque `nodeId` strings and has no concept of types. The `DataSource` supersedes it by adding:

- **Type awareness** — every operation is scoped to a `typeName`
- **Schema discovery** — `discoverTypes()` / `typeFor()`
- **Named relations** — `fetchChildren()` replaces generic `fetchElements()`

The `DataSource` interface will be implemented by adapters that wrap the existing `SqliteRepositoryAdapter` (or Firebase, gRPC, REST equivalents). The old `AbstractRepository` is either absorbed into the `DataSource` or kept as a backward-compatibility shim during migration.

---

## 3. Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                      DataSource (pluggable)                       │
│                                                                   │
│  SqliteDataSource  ──  FirebaseDataSource  ──  GrpcDataSource     │
│  discoverTypes() ─── typeFor() ─── CRUD ─── watchProperties()     │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           ▼
                TypeDescriptor[]
                 │       │        │
          ┌──────┘       │        └──────────┐
          ▼              ▼                   ▼
   TreeViewModel   PropertyViewModel   TablesViewModel
   reads childTypes reads fields        reads childTypes
   renders ANY tree renders ANY form    renders ANY table
          │              │                   │
          ▼              ▼                   ▼
   TreeNodeWidget   PropertyGrid        TableViewWidget
   (no switch)      (no if/else)         (no hardcoded IDs)

   TopologyViewModel reads links → renders ANY graph
```

### Data flow

```
App starts
  │
  ├── 1. Select DataSource (DI / config file / env var)
  │
  ├── 2. dataSource.discoverTypes() → TypeDescriptor[]
  │     │
  │     ├── typeName: "Chassis"
  │     ├── icon: Icons.dns
  │     ├── fields: [FieldDescriptor(key:"maxVoltage", type:double, ...), ...]
  │     ├── childTypes: [TypeRelation(relation:"contains", targetType:"Sensor"), ...]
  │     └── parentTypes: [TypeRelation(relation:"contained_by", targetType:"Rack"), ...]
  │
  ├── 3. TypeDescriptor[] → build tree (TreeViewModel)
  │     │
  │     └── TreeNode.icon ← typeDescriptor.icon  (no switch)
  │
   ├── 4. User selects node → typeDescriptor.fields → PropertyGrid
   │     │
   │     └── sectionLabel / sectionOrder / validation / formatters ← FieldDescriptor
   │     └── refType → fields render as hyperlinks → onViewSelected navigates to referenced type instance
   │
   ├── 5. User navigates to child table → typeDescriptor.childTypes → table columns
   │
   └── 6. User invokes an operation → actionDescriptor.name → dataSource.invokeAction()
         │
         └── actionDescriptor (label, icon, confirmation prompt, input params)
```

---

## 7. Navigation and Drill-Down

### 7.1 Reference Navigation (FieldDescriptor.refType)

Fields that reference another managed object carry `refType` — the type name of the referenced entity. The UI renders these fields as clickable hyperlinks rather than plain text.

```
PropertyGrid / TableViewWidget
  └─ field.descriptor.refType != null
       └─ cell rendered as styled link (underlined, primary color)
            └─ on tap → onViewSelected(refType, fieldValue)
                 └─ Layout rebuilds detail pane for the referenced type
```

`refType` enables the master-detail drill-down pattern:
- Device detail view shows a `parent_rack` reference → click navigates to rack
- Service detail view shows a `parent_device` reference → click navigates to device
- Alarm detail view shows an `affected_service` reference → click navigates to service

### 7.2 Breadcrumb Trail

The `NavigationBreadcrumbs` widget (`lib/features/layout/breadcrumbs.dart`) reads the current view ID and walks the type hierarchy via `TreeViewModel.treeData` to build a `List<BreadcrumbItem>`. Each item is clickable and calls `onSelectView(id)`, enabling arbitrary-depth drill-up.

### 7.3 Cross-Type Navigation Flow

```
Device detail (viewing device-42)
  ├─ clicks "parent_rack" reference (refType: rack, id: rack-07)
  │    └─ Layout._selectView("rack-07")
  │         └─ PropertyGrid reloads for rack-07
  │         └─ Breadcrumbs updates: [Home > Device > Rack]
  │
  ├─ clicks "supported_services" child tab
  │    └─ TableViewWidget shows child type "Service" rows
  │         └─ clicks a service row → Layout._selectView("service-99")
  │              └─ PropertyGrid reloads for service-99
  │              └─ Breadcrumbs updates: [Home > Device > Service]
  │
  └─ clicks "Compute Path" action button
       └─ dataSource.invokeAction("device-42", "compute_path", params)
            └─ returns path result → displayed in result panel
```

---

## 8. Action / Invocation Model

The blueprint's `DataSource` interface describes CRUD + schema discovery. Real managed objects also expose **operations** — actions the user can invoke that go beyond property editing.

### 8.1 ActionDescriptor

```dart
class ActionDescriptor {
  final String name;              // "compute_path", "reboot", "deploy"
  final String label;             // "Compute Path", "Reboot Device"
  final IconData icon;            // icon shown on the button
  final String? confirmation;     // confirmation dialog text; null = no confirmation
  final List<ActionParameterDescriptor>? parameters; // input params
  final bool destructive;         // if true, require extra confirmation
}

class ActionParameterDescriptor {
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumOptions;
}
```

### 8.2 DataSource Extensions

```dart
abstract class DataSource {
  // Existing CRUD methods...

  /// Return the actions available for a given type.
  Future<List<ActionDescriptor>> getActions(String typeName);

  /// Invoke an action on an instance. Returns a result map.
  Future<Map<String, dynamic>> invokeAction(
    String typeName,
    String instanceId,
    String actionName,
    Map<String, dynamic> parameters,
  );
}
```

### 8.3 UI Rendering

Actions appear in a dedicated section of the detail view (below the property form, or as a toolbar):

```
PropertyGrid  (or dedicated ActionPanel)
  └─ ActionBar
       ├─ [Compute Path]     — non-destructive, no confirmation
       ├─ [Reboot Device]    — destructive, confirmation dialog
       └─ [Deploy Config]   — requires parameter input dialog
```

Action buttons are enabled/disabled based on the object's lifecycle state (§9). Destructive actions show a confirmation dialog before invocation.

### 8.4 Invocation Result

After invocation, the result is displayed (success/failure, output data, or error). On success, the relevant views refresh automatically.

---

## 9. Lifecycle State Model

Managed objects pass through lifecycle states. The UI reflects the current state through badges, color coding, and action availability.

```dart
enum LifecycleState {
  discovered,
  provisioning,
  active,
  degraded,
  decommissioned,
  failed,
}

class TypeDescriptor {
  // Existing fields...
  final LifecycleState? currentState;  // current object state
}
```

### 9.1 State-Indicator Rendering

The detail view header shows the current state as a colored badge:

| State | Color | Action Availability |
|---|---|---|
| discovered | grey | All actions available |
| provisioning | amber | No actions (waiting for completion) |
| active | green | All actions available |
| degraded | orange | Read-only (Save disabled) |
| decommissioned | grey | Read-only, no actions |
| failed | red | Retry actions only |

### 9.2 State Transitions

Actions can transition the object between states. The `ActionDescriptor.destructive` flag determines whether the state transition requires confirmation.

---

## 10. Responsive Layout and Progressive Disclosure

Each detail widget adapts its presentation to available width. The `SplitWorkspace` notifies child widgets of their pane size, enabling breakpoint-based layout switches.

### 10.1 Breakpoint Constants

```dart
/// Per-widget layout modes derived from available width.
enum WidgetLayoutMode {
  compact,    // < 400px  — phone or narrow split pane
  medium,     // 400–800px — typical half-split
  expanded,   // > 800px   — full-width or nearly full
}
```

Each widget derives its mode from the available width (via `LayoutBuilder` or a passed-in `WidgetLayoutMode`).

### 10.2 Widget Adaptation Contracts

| Widget | Compact | Medium | Expanded |
|--------|---------|--------|----------|
| **PropertyGrid** | Key-value list, collapsible sections | Single-column, section headers truncatable | Multi-column sections, side-by-side cards |
| **TableViewWidget** | Card-list view | Reduced columns, auto-hide low-priority | Full columns, frozen columns |
| **TopologyMap** | Minimap + play/pause only | Compact playback, no labels | Full canvas, labels, velocity vectors |
| **TreeSidebar** | Icons only | Icons + truncated labels | Full labels + counts |

### 10.3 Implementation

Widgets do not need to know their parent's layout — they receive available width through the normal Flutter layout system (`LayoutBuilder`, `BoxConstraints`). The `SplitWorkspace` may optionally provide a `ValueNotifier<WidgetLayoutMode>` for widgets that need proactive adjustment.

---

## 4. Current Architecture Gaps (updated numbering)

### `app_flutter/lib/features/tree/tree_node_widget.dart`

| Current | Problem | TypeDescriptor fix |
|---|---|---|
| `switch (node.id)` on 6 hardcoded IDs (`Ingestion`, `Metrics`, `Location`, `Chassis`, `Epics`, `Traceability`) to pick `IconData` (lines 26-48) | New object types require code changes + recompile | `typeDescriptor.icon` — every type knows its own icon |
| Parent nodes get `Icons.folder` / `Icons.folder_open` (lines 23-24) | Assumes all expandable nodes are folders | `typeDescriptor.icon` applies uniformly; parent/child distinction is a tree-state concern, not icon concern |

### `app_flutter/lib/features/properties/property_grid.dart`

| Current | Problem | TypeDescriptor fix |
|---|---|---|
| `const _sectionLocation = 'Location'`, `_sectionAlternate = 'Alternate'` (lines 45-46) | Hardcodes domain-specific section IDs | Sections are derived from `FieldDescriptor.sectionLabel`; no named constants needed |
| `sortedGroups` sort with if/else prioritizing `Location` > `Alternate` (lines 281-287) | Sort order cannot be configured per data source | `fieldDescriptor.sectionOrder` — sort numerically, no branches |
| Active section logic: `if/else` on `_sectionLocation`, `_sectionAlternate`, `_viewIngestion` (lines 301-303) | Cannot handle new sections from a different domain | Section visibility is a render-time decision driven purely by section metadata; see generic algorithm in §3 of old blueprint (the `isSectionActive` logic remains valid, just driven by `FieldDescriptor.sectionLabel` instead of hardcoded group names) |
| Hardcoded `_keyCountryCode` formatters: `UpperCaseTextFormatter` + `LengthLimitingTextInputFormatter(2)` (lines 519-524) | Per-field formatters baked into widget | `fieldDescriptor.inputFormatters` describes formatters generically |
| `_typeDouble`, `_typeInt`, `_typeEnum` string constants (lines 48-50) | Redundant indirection | Use `fieldDescriptor.type` directly |
| `widget.shouldPair` default from `property_defaults.dart` (line 38+) | Pairing rules hardcoded per domain | Paired rendering is a UI decision based on section adjacency — no `shouldPair` needed when sections already group logically related fields |

### `app_flutter/lib/features/properties/property_defaults.dart`

| Current | Problem | TypeDescriptor fix |
|---|---|---|
| `defaultFallbackInitialValues` — 10 hardcoded mock values (lines 7-18) | Domain-specific defaults baked into code | `fieldDescriptor.defaultValue` from each data source |
| `defaultOptionDisplayNames` — display names for `locationType` enum (lines 21-28) | Enum display names hardcoded | `fieldDescriptor.enumDisplayNames` |
| `defaultShouldPair` — static pairing rules for `gridRow/gridColumn`, `maxVoltage/maxAllocatedPower`, `countryCode/locationType` (lines 31-35) | Pairing logic cannot be extended for new types | Eliminated — sections group fields by `sectionLabel`; paired display is a generic layout optimization |
| `defaultValidator` — validation per key (`countryCode`, `locationType`, `maxVoltage`/`maxAllocatedPower`) (lines 38-89) | Validation rules hardcoded per domain | `fieldDescriptor.minValue` / `maxValue` / `pattern` / `required` |
| **Entire file** must be deleted | — | — |

### `app_flutter/lib/domain/schema.dart`

| Current | Problem | TypeDescriptor fix |
|---|---|---|
| `AttributeDefinition` is a compile-time model with domain-specific `defaultCoordinateAttributes` const list (lines 57-129) | The schema is baked into the binary | `FieldDescriptor` replaces `AttributeDefinition`; no const lists — all schemas come from `DataSource.discoverTypes()` |
| `options` is `List<String>?` (line 5) — no display names | Lossy — cannot show user-friendly labels | `FieldDescriptor.enumOptions` + `enumDisplayNames` |
| No `sectionLabel`, `sectionOrder`, `pairedWith`, `inputFormatters`, `defaultValue` | Missing metadata that forced hardcoded workarounds | All present in `FieldDescriptor` |

### `app_flutter/lib/domain/repository.dart`

| Current | Problem | DataSource fix |
|---|---|---|
| `fetchProperties(String nodeId)` — no type awareness | Tree could mix Sensors and Chassis; properties are fetched blind | `dataSource.fetchProperties(typeName, instanceId)` — scoped by type |
| `fetchElements(String parentNodeId)` — generic child fetch | No way to distinguish "contains" vs "connected_to" vs "depends_on" | `dataSource.fetchChildren(typeName, parentId, relationName)` — named relations |
| No schema discovery methods | Client cannot know what fields exist | `dataSource.discoverTypes()` + `typeFor()` |

### `app_flutter/lib/features/layout/layout.dart`

| Current | Problem | DataSource fix |
|---|---|---|
| `_resolveTabLabel` with hardcoded fallbacks (lines 185-188) | Tab labels baked into code | Tab labels come from `TypeRelationDescriptor.displayLabel` or data source |
| `_buildChildWidget` parses `attributes` from `_parsedLayout` (lines 294-304) | Schema comes from JSON, not the data source | Properties view reads `typeDescriptor.fields` from the connected data source |
| Entire layout assumes `logical-layout.json` is the single source of truth | JSON is just hardcoding in a different format | `DataSource` is the single source of truth; `logical-layout.json` is demoted to a layout-only config (position, sizing, split ratios) with no domain schema |

### `app_flutter/lib/features/layout/component_factory.dart`

| Current | Problem | DataSource fix |
|---|---|---|
| `TableView` hardcodes `AbstractRepository` (line 134) | No type awareness for table columns | Table ViewModel reads `typeDescriptor.fields` for column definitions |
| No dynamic widget dispatch per type | Every view expects same schema shape | ComponentFactory can use `typeDescriptor.typeName` to select specialized views if needed |

---

## 5. Data Source Implementations (Conceptual)

### 5.1 SQLite

The SQLite database contains dedicated metadata tables that the data source queries to build `TypeDescriptor` instances:

```sql
-- Metadata tables (new)
CREATE TABLE type_definitions (
  type_name       TEXT PRIMARY KEY,
  display_name    TEXT NOT NULL,
  icon_name       TEXT NOT NULL        -- Material icon name
);

CREATE TABLE type_attributes (
  id              INTEGER PRIMARY KEY,
  type_name       TEXT NOT NULL REFERENCES type_definitions(type_name),
  key             TEXT NOT NULL,
  label           TEXT NOT NULL,
  field_type      TEXT NOT NULL,        -- "string", "int", "double", "enum", "date", "bool"
  section_label   TEXT,
  section_order   INTEGER DEFAULT 0,
  is_required     INTEGER DEFAULT 0,
  min_value       REAL,
  max_value       REAL,
  pattern         TEXT,
  enum_options    TEXT,                 -- JSON array or comma-separated
  enum_display_names TEXT,              -- JSON map
  default_value   TEXT,
  input_formatters TEXT,                -- JSON array of formatter descriptors
  FOREIGN KEY (type_name) REFERENCES type_definitions(type_name)
);

CREATE TABLE type_relations (
  id              INTEGER PRIMARY KEY,
  parent_type     TEXT NOT NULL,
  relation_name   TEXT NOT NULL,
  child_type      TEXT NOT NULL,
  display_label   TEXT NOT NULL,
  FOREIGN KEY (parent_type) REFERENCES type_definitions(type_name),
  FOREIGN KEY (child_type) REFERENCES type_definitions(type_name)
);
```

```dart
class SqliteTypeDescriptor implements TypeDescriptor {
  final String typeName;
  final String displayName;
  final IconData icon;
  final List<FieldDescriptor> fields;
  final List<TypeRelationDescriptor> childTypes;
  final List<TypeRelationDescriptor> parentTypes;

  SqliteTypeDescriptor.fromDb(Map<String, dynamic> row, List<FieldDescriptor> fields,
      List<TypeRelationDescriptor> childTypes, List<TypeRelationDescriptor> parentTypes)
      : typeName = row['type_name'],
        displayName = row['display_name'],
        icon = IconMapper.resolve(row['icon_name']),
        fields = fields,
        childTypes = childTypes,
        parentTypes = parentTypes;
}

class SqliteDataSource implements DataSource {
  final Database db;

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final typeRows = await db.query('type_definitions');
    final descriptors = <TypeDescriptor>[];
    for (final row in typeRows) {
      descriptors.add(await _buildDescriptor(row['type_name']));
    }
    return descriptors;
  }

  Future<TypeDescriptor> _buildDescriptor(String typeName) async {
    // Query type_attributes + type_relations → build TypeDescriptor
  }
  // ... fetchProperties, saveProperties, watchProperties ...
}
```

**Existing data tables** (`properties`, `elements`, `alarms`, `events`) remain unchanged — they store instance data. The new `type_definitions`, `type_attributes`, and `type_relations` tables store the schema that was previously hardcoded or in `logical-layout.json`.

### 5.2 Firebase

```dart
class FirebaseDataSource implements DataSource {
  final FirebaseFirestore firestore;

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final snapshot = await firestore.collection('schema/types').get();
    return snapshot.docs.map((doc) => FirebaseTypeDescriptor.fromFirestore(doc)).toList();
  }

  // Each type document in Firestore:
  // collection("schema").document("Chassis") → {
  //   displayName: "Chassis",
  //   icon: "dns",
  //   fields: [
  //     { key: "maxVoltage", label: "Max Voltage (V)", fieldType: "double", ... }
  //   ],
  //   childTypes: [
  //     { relationName: "contains", targetType: "Sensor", displayLabel: "Sensors" }
  //   ]
  // }
}
```

### 5.3 gRPC / Protobuf

```dart
class GrpcDataSource implements DataSource {
  // Uses protobuf reflection or FileDescriptorSet to build TypeDescriptors.
  //
  // The .proto file defines the schema:
  //   message Chassis {
  //     string id = 1;
  //     double max_voltage = 2 [(constraint) = "min:0, max:10000"];
  //     double max_allocated_power = 3 [(constraint) = "min:0"];
  //     string country_code = 4 [(validate) = "regex:^[A-Z]{2}$"];
  //     LocationType location_type = 5;
  //   }
  //
  // Proto field types → FieldType enum
  // Proto custom options → minValue, maxValue, pattern, etc.
  // Proto oneof / enum → FieldType.enum_ with options
  // Message nesting → childTypes

  @override
  Future<TypeDescriptor> typeFor(String typeName) async {
    final descriptor = _pool.findMessageByName(typeName);
    return ProtoTypeDescriptor(descriptor);
  }
}
```

**Key insight**: The `.proto` file **is** the metadata. Field names, types, relationships, and even constraints (via custom proto options) are all defined in the protobuf schema. No parallel JSON schema is needed.

### 5.4 REST

```dart
class RestDataSource implements DataSource {
  final HttpClient client;
  final String baseUrl;

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final response = await client.get('$baseUrl/api/schema/types');
    // Expects JSON Schema or custom schema format:
    // GET /api/schema/types → {
    //   "types": [
    //     {
    //       "typeName": "Chassis",
    //       "displayName": "Chassis",
    //       "icon": "dns",
    //       "fields": [...],
    //       "childTypes": [...]
    //     }
    //   ]
    // }
    return response.types.map((t) => RestTypeDescriptor.fromJson(t)).toList();
  }
}
```

---

## 6. Migration Strategy

Each phase is independently testable — the app never enters a state where it depends on metadata that hasn't been deployed.

### Phase 1: Define abstractions (no behavior change)

1. Create `TypeDescriptor`, `FieldDescriptor`, `TypeRelationDescriptor`, `DataSource` as pure abstract classes in `lib/domain/`
2. Create `IconMapper` service (as already described in v1 blueprint) — a static map from string to `IconData`
3. **Test**: Compiles, zero behavioral change, all existing tests pass

### Phase 2: Implement SqliteTypeDescriptor + DB schema

1. Create `type_definitions`, `type_attributes`, `type_relations` tables in SQLite
2. Write seed migration that populates them from the current `logical-layout.json` + hardcoded `defaultCoordinateAttributes`
3. Implement `SqliteTypeDescriptor` and `SqliteDataSource`
4. **Test**: `SqliteDataSource.discoverTypes()` returns a `TypeDescriptor` for each type; the result matches what was previously hardcoded

### Phase 3: Wire TypeDescriptor into ViewModels (one at a time)

Each ViewModel currently reads from hardcoded sources. Replace with reads from `TypeDescriptor`:

#### 3a. TreeViewModel
- Add `List<TypeDescriptor>` to `TreeViewModel`
- Replace `switch(node.id)` icon resolution with `typeDescriptor.icon` via `IconMapper`
- **Test**: Tree renders identical icons, but icons now come from the data source

#### 3b. PropertyViewModel (replaces PropertiesService + PropertyGrid defaults)
- Read `typeDescriptor.fields` instead of `defaultCoordinateAttributes`
- Replace hardcoded section titles and sort order with `fieldDescriptor.sectionLabel` / `sectionOrder`
- Implement generic `isSectionActive()` algorithm (as described in v1 §4)
- Replace `defaultValidator` with `fieldDescriptor.minValue/maxValue/pattern/required`
- Replace `defaultFallbackInitialValues` with `fieldDescriptor.defaultValue`
- Replace `defaultOptionDisplayNames` with `fieldDescriptor.enumDisplayNames`
- Replace `_keyCountryCode` formatters with `fieldDescriptor.inputFormatters`
- Delete `property_defaults.dart`
- **Test**: Property form renders identically for existing types; adding a new type in DB produces a correct form with zero code changes

#### 3c. TablesViewModel
- Read `typeDescriptor.childTypes` to determine table columns
- Replace hardcoded `testId` switch/case
- **Test**: Table columns match the data source schema

### Phase 4: Connect DataSource to AbstractRepository

1. Add a `DataSource` field to `Layout` (or inject it via DI)
2. Have `SqliteDataSource` wrap the existing `SqliteRepositoryAdapter`
3. Replace direct `AbstractRepository` calls with `DataSource` calls in ViewModels
4. Remove the `attributes` array from `logical-layout.json` — schema now comes from `DataSource.discoverTypes()`
5. Keep `logical-layout.json` only for layout structure (position, sizing, split ratios)
6. **Test**: Full regression — app runs identically, but schema comes from the database

### Phase 5: Firebase implementation (swappability proof)

1. Implement `FirebaseDataSource` using the same `DataSource` interface
2. Create a switch at app startup: read `DataSource` type from config
3. **Test**: App launches with Firebase backend, discovers types from Firestore, renders identical UI

### Phase 6: gRPC / Protobuf implementation

1. Implement `GrpcDataSource` using protobuf reflection
2. **Test**: App connects to a gRPC endpoint, discovers types from `.proto` descriptors, renders identical UI
3. Optional: add REST implementation similarly

### Phase 7: Cleanup

1. Remove `property_defaults.dart` (if not already removed in Phase 3b)
2. Remove `defaultCoordinateAttributes` from `schema.dart`
3. Remove `_typeDouble`, `_typeInt`, `_typeEnum` from `property_grid.dart`
4. Remove layout-parser schema parsing from `layout.dart` / `layout_parser.dart`
5. **Test**: No hardcoded domain data remains in the codebase

---

## 7. Risk Assessment

### 7.1 Breakage Risks

| Risk | Impact | Mitigation |
|---|---|---|
| `DataSource.discoverTypes()` returns empty list | App shows empty tree, no properties | Default to a minimal fallback `TypeDescriptor` (one "Unknown" type) or show a "no data source" screen |
| `FieldDescriptor.enumOptions` vs old `options` string list mismatch | Enum fields render with no options | `FieldDescriptor` accepts both formats at construction; provide a static `fromLegacyAttributes(List<String>)` factory |
| `AbstractRepository` consumers not yet migrated | Broken property loading | Phase 3/4 keeps both paths alive via a facade that delegates to `DataSource` when available, falls back to `AbstractRepository` |
| `logical-layout.json` `attributes` array removed before ViewModels are migrated | Property grid shows no fields | Remove `attributes` from JSON only at Phase 4, after ViewModels read from `DataSource` |
| Tree icons change visually during migration | UX regression | Phase 3a seeds `IconMapper` with the same icon names already used in the hardcoded switch — no visual change |
| DB migration of type_definitions table fails | App starts with no schema | Seed the migration from `logical-layout.json` at first launch; version the schema and fall back to the embedded JSON if DB tables are empty |
| gRPC `.proto` custom options for validation (min, max, regex) are not standard protobuf | Constraints are invisible | Define a well-known custom option proto (`validate.proto`) and document it; if absent, no constraint is applied (graceful degradation) |
| Multiple data sources active simultaneously | Confusion about which source provides schema | The app selects one `DataSource` at startup via DI / config; future work could merge multiple sources |
| `FieldDescriptor.sectionLabel` is null | Field appears in an unnamed section | Group into an "Other" section sorted last |

### 7.2 Performance

| Concern | Assessment |
|---|---|
| `discoverTypes()` queries on every startup | DB or Firestore query for N types is O(N) with small N (<100 types); negligible. Cache in memory after first load |
| `IconMapper` resolution | Static map lookup O(1); no runtime overhead |
| `TypeDescriptor` object count | One per object type, not per instance — minimal memory |
| gRPC reflection for schema | Proto reflection is a small RPC call; cache the FileDescriptorSet after discovery |

### 7.3 Backward Compatibility

- Phase 1-3: zero behavioral change — existing hardcoded paths remain in parallel
- Phase 4: `AbstractRepository` wrapped by `SqliteDataSource` — all existing call sites continue to work
- Phase 5-6: new data sources are opt-in via config; default remains SQLite
- `logical-layout.json` retains its `attributes` array until Phase 4; after removal, old layouts with embedded attributes are ignored (the data source is the source of truth)
