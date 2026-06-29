# Runtime Metadata Architecture Blueprint

> Goal: Make the Flutter app fully metadata-driven — discovering all object types, properties, labels, icons, and validation rules at runtime with zero code changes when new object types are added to the data source.

---

## 1. Current Hardcoding Inventory

| File | Hardcoded Data | Line(s) | Schema Field That Replaces It |
|---|---|---|---|
| `tree_node_widget.dart` | Icon mapping: `node.id` → `IconData` (switch/case on `Ingestion`, `Metrics`, `Location`, `Chassis`, `Epics`, `Traceability`) | 26–48 | `icon` (string) in hierarchy node JSON |
| `tree_node.dart` | `TreeNode` model lacks `icon` and `type` fields | 2–11 | Add `icon` (String?) and `type` (String?) fields |
| `layout_parser.dart` | `parseTreeHierarchy` ignores `icon` and `type` keys | 54–70 | Parse `icon` and `type` from JSON into `TreeNode` |
| `property_grid.dart` | Section titles: `"Geodetic Coordinate Frame"` for group `"Location"`, `"Alternate Structural Grid Frame"` for group `"Alternate"` | 305–310 | `sectionLabel` in attribute JSON |
| `property_grid.dart` | Section ordering: `sortedGroups` with switch/case prioritizing `"Location"` then `"Alternate"` | 281–287 | `sectionOrder` in attribute JSON (or section-level metadata) |
| `property_grid.dart` | Active section logic: `if/else` checking `_sectionLocation`, `_sectionAlternate`, `_viewIngestion` | 301–303 | Generic algorithm: section active when `sectionGroup` matches `activeView` or any ancestor view |
| `property_grid.dart` | Country-code formatters: `UpperCaseTextFormatter` + `LengthLimitingTextInputFormatter(2)` hardcoded for `_keyCountryCode` | 519–524 | `inputFormatters` like `"uppercase"`, `"maxLength": 2` in attribute JSON |
| `property_grid.dart` | Constants: `_typeDouble`, `_typeInt`, `_typeEnum` | 48–50 | Use `attr.type` directly |
| `property_defaults.dart` | `defaultFallbackInitialValues` — mock values for 10 fields | 7–18 | Delete entirely; fallback uses `attr.defaultValue` from schema |
| `property_defaults.dart` | `defaultOptionDisplayNames` — display names for `locationType` enum values | 21–28 | `optionDisplayNames` map in each enum attribute's `options` array |
| `property_defaults.dart` | `defaultShouldPair` — pairing rules for `gridRow/gridColumn`, `maxVoltage/maxAllocatedPower`, `countryCode/locationType` | 31–35 | `pairKey` or `pairedWith` attribute in attribute JSON |
| `property_defaults.dart` | `defaultValidator` — hardcoded validation per key (`countryCode`, `locationType`, `maxVoltage`/`maxAllocatedPower`) | 38–89 | Delete; use `minValue`, `maxValue`, `regexPattern`, `isRequired` from attribute JSON |
| `topology_map.dart` | Status colors: `activeStatusColor` = `colors.tertiary`, `warningStatusColor` = `colors.error` | 495–496 | `statusColorMapping` or `statusColor` in topology node data |
| `topology_map.dart` | Node paint logic: `node.status == 'Active'` branch determines fill color | 640–646 | Use color from `statusColorMapping` keyed by `node.status` |
| `table_view_widget.dart` | `testId` switch/case on `viewModel.tabId` | 31–35 | Use `tabId` directly or read from layout config |
| `layout.dart` | Tab label fallbacks: `sub_elements_table` → `"Items"`, etc. | 185–188 | Read label from layout config's `props.label` |

---

## 2. Target Runtime Data Model

### 2.1 Extended `logical-layout.json` Schema

```json
{
  "$schema": "https://example.com/schemas/logical-layout-v2.json",
  "meta": {
    "version": "2.0.0",
    "schema_name": "systems_topology_dashboard"
  },
  "theme": { /* unchanged */ },

  "hierarchy": [
    {
      "id": "Ingestion",
      "label": "Ingestion",
      "icon": "play_arrow",
      "type": "process",
      "children": []
    },
    {
      "id": "Monitoring",
      "label": "Monitoring",
      "icon": "monitoring",
      "type": "category",
      "children": [
        {
          "id": "Metrics",
          "label": "Metrics",
          "icon": "bar_chart",
          "type": "collector"
        },
        {
          "id": "Location",
          "label": "Location",
          "icon": "location_on",
          "type": "collector"
        },
        {
          "id": "Chassis",
          "label": "Chassis",
          "icon": "dns",
          "type": "hardware"
        },
        {
          "id": "Uptime",
          "label": "Uptime",
          "icon": "timer",
          "type": "monitor"
        }
      ]
    }
  ],

  "sections": [
    {
      "id": "Location",
      "label": "Geodetic Coordinate Frame",
      "order": 0,
      "activeWhen": ["Location", "Ingestion"]
    },
    {
      "id": "Alternate",
      "label": "Alternate Structural Grid Frame",
      "order": 1,
      "activeWhen": []
    },
    {
      "id": "interface",
      "label": "Interface Configuration",
      "order": 2,
      "activeWhen": ["Network", "InterfaceConfig"]
    },
    {
      "id": "state",
      "label": "Interface State",
      "order": 3,
      "activeWhen": ["Network"]
    }
  ],

  "attributes": [
    {
      "key": "interfaces/interface/name",
      "label": "The name of the interface",
      "type": "string",
      "sectionGroup": "interface",
      "isRequired": false
    },
    {
      "key": "interfaces/interface/state/mtu",
      "label": "The Maximum Transmission Unit",
      "type": "int",
      "sectionGroup": "state",
      "isRequired": true,
      "minValue": 68,
      "maxValue": 9216
    },
    {
      "key": "interfaces/interface/state/admin-status",
      "label": "The administrative status of the interface",
      "type": "enumeration",
      "sectionGroup": "state",
      "isRequired": false,
      "options": [
        { "value": "UP", "displayName": "Up" },
        { "value": "DOWN", "displayName": "Down" }
      ]
    },
    {
      "key": "latitude",
      "label": "Latitude",
      "type": "double",
      "sectionGroup": "Location",
      "isRequired": false,
      "minValue": -90,
      "maxValue": 90
    },
    {
      "key": "longitude",
      "label": "Longitude",
      "type": "double",
      "sectionGroup": "Location",
      "isRequired": false,
      "minValue": -180,
      "maxValue": 180
    },
    {
      "key": "countryCode",
      "label": "Country Code (ISO-2)",
      "type": "string",
      "sectionGroup": "Alternate",
      "isRequired": false,
      "regexPattern": "^[A-Z]{2}$",
      "inputFormatters": {
        "uppercase": true,
        "maxLength": 2
      }
    },
    {
      "key": "gridRow",
      "label": "Grid Row",
      "type": "int",
      "sectionGroup": "Alternate",
      "isRequired": false,
      "pairedWith": "gridColumn"
    },
    {
      "key": "gridColumn",
      "label": "Grid Column",
      "type": "int",
      "sectionGroup": "Alternate",
      "isRequired": false,
      "pairedWith": "gridRow"
    },
    {
      "key": "maxVoltage",
      "label": "Max Voltage (V)",
      "type": "double",
      "sectionGroup": "Alternate",
      "isRequired": false,
      "pairedWith": "maxAllocatedPower",
      "minValue": 0
    },
    {
      "key": "maxAllocatedPower",
      "label": "Max Allocated Power (W)",
      "type": "double",
      "sectionGroup": "Alternate",
      "isRequired": false,
      "pairedWith": "maxVoltage",
      "minValue": 0
    }
  ],

  "viewTypeConfigs": {
    "collector": {
      "defaultIcon": "bar_chart",
      "topologyStatusColors": {
        "Active": "#4CAF50",
        "Idle": "#FF9800",
        "Warning": "#F44336",
        "Offline": "#9E9E9E"
      }
    },
    "process": {
      "defaultIcon": "settings",
      "topologyStatusColors": {
        "Active": "#2196F3",
        "Idle": "#FF9800",
        "Warning": "#F44336"
      }
    }
  }
}
```

### 2.2 Attribute JSON — Extended Fields

| Field | Type | Description | Replacement For |
|---|---|---|---|
| `key` | string | Attribute identifier | — |
| `label` | string | Display label | — |
| `type` | `"string"` \| `"int"` \| `"double"` \| `"enumeration"` | Data type | — |
| `sectionGroup` | string | Section this attribute belongs to | — |
| `sectionLabel` | string | Human-readable section title | Hardcoded `"Geodetic Coordinate Frame"` etc. |
| `sectionOrder` | int | Position among sections | Hardcoded sort logic |
| `isRequired` | bool | Required field flag | — |
| `minValue` | number | Min constraint (numeric types) | Hardcoded validation |
| `maxValue` | number | Max constraint (numeric types) | Hardcoded validation |
| `regexPattern` | string | Regex validation (string types) | Hardcoded `defaultValidator` |
| `options` | `[{value, displayName}]` | Enum options with display names | `defaultOptionDisplayNames` |
| `pairedWith` | string | Key of paired sibling attribute | `defaultShouldPair` |
| `inputFormatters` | `{uppercase?, maxLength?, ...}` | Client-side input formatting rules | Hardcoded country-code formatters |
| `defaultValue` | any | Default value when none provided | `defaultFallbackInitialValues` |

### 2.3 Hierarchy Node — Extended Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `label` | string | Display label |
| `icon` | string | Material icon name (e.g. `"bar_chart"`, `"location_on"`) |
| `type` | string | Object type key (e.g. `"collector"`, `"process"`, `"category"`) |
| `children` | `TreeNode[]` | Child nodes |

### 2.4 Section Metadata — New Top-Level Array

```json
{
  "sections": [
    {
      "id": "Location",
      "label": "Geodetic Coordinate Frame",
      "order": 0,
      "activeWhen": ["Location"]
    }
  ]
}
```

| Field | Type | Description |
|---|---|---|
| `id` | string | Matches attribute `sectionGroup` |
| `label` | string | Display title |
| `order` | int | Sorting order among sections |
| `activeWhen` | string[] | List of view IDs that activate this section; empty = always inactive unless the view ID matches directly |

### 2.5 `viewTypeConfigs` — New Top-Level Object

Maps `type` (from hierarchy node) to configuration:

```json
{
  "viewTypeConfigs": {
    "collector": {
      "defaultIcon": "bar_chart",
      "topologyStatusColors": {
        "Active": "#4CAF50",
        "Idle": "#FF9800"
      }
    }
  }
}
```

This replaces hardcoded topology status colors by letting each object type define its own color scheme keyed by `TopologyNode.status`.

---

## 3. Widget Changes Required

### 3.1 `tree_node_widget.dart` and `tree_node.dart`

| Current | Target |
|---|---|
| `switch (node.id)` on 6 known IDs to select `IconData` | `TreeNode` has `icon` field (string); read it directly |
| Imports `Icons.*` directly | Delegate to a `IconMapper` service: `IconMapper.resolve(node.icon)` returns `IconData` |
| `TreeNode` has 3 fields: `id`, `label`, `children` | Add `icon` (String?) and `type` (String?) |

### 3.2 `layout_parser.dart`

| Current | Target |
|---|---|
| Only parses `id` and `label` from hierarchy nodes | Parse `icon`, `type` into `TreeNode` constructor |
| Ignores `sections` array | Parse `sections` into a new `SectionDefinition` model |
| Ignores `viewTypeConfigs` | Parse into a `ViewTypeConfig` map |

### 3.3 `property_grid.dart`

| Current | Target |
|---|---|
| `const _sectionLocation = 'Location'` and `_sectionAlternate = 'Alternate'` | Delete; sections are discovered from metadata |
| `sortedGroups` with hardcoded priority: `"Location"` → `"Alternate"` → rest | Read `sectionOrder` from section metadata |
| `if (group == _sectionLocation) title = 'Geodetic Coordinate Frame'` | Read `sectionLabel` from section metadata |
| Active-section logic: `if/else` on `_sectionLocation`, `_sectionAlternate`, `_viewIngestion` | Generic algorithm (see §4) |
| `_keyCountryCode` + hardcoded formatters | Read `inputFormatters` from attribute JSON |
| `_typeDouble`, `_typeInt`, `_typeEnum` string constants | Use `attr.type` as-is |
| `widget.shouldPair` (imported from `property_defaults.dart`) | Read `pairedWith` from attribute JSON, group adjacent paired fields |
| `widget.validator` (imported from `property_defaults.dart`) | Delete; validation comes from `minValue`, `maxValue`, `regexPattern`, `isRequired` on each attribute |
| `widget.optionDisplayNames` (imported from `property_defaults.dart`) | Delete; display names come from `options[].displayName` |
| `widget.fallbackInitialValues` (imported from `property_defaults.dart`) | Delete; defaults come from `attr.defaultValue` |

### 3.4 `property_defaults.dart`

| Current | Target |
|---|---|
| Entire file (4 exported defaults) | **Delete** — all logic moved to attribute metadata |

### 3.5 `topology_map.dart`

| Current | Target |
|---|---|
| `TopologyPainterColors` has `activeStatusColor` and `warningStatusColor` as fixed `Color` fields | Accept a `statusColorMapping` parameter (e.g. `Map<String, Color>`) passed from metadata |
| `node.status == 'Active' ? colors.activeStatusColor : colors.warningStatusColor` | `statusColorMapping[node.status] ?? fallbackColor` |
| Colors hardcoded in `build()` at line 495–496 | Colors resolved from `viewTypeConfigs[viewType].topologyStatusColors` |

### 3.6 `table_view_widget.dart`

| Current | Target |
|---|---|
| `testId` switch/case on `viewModel.tabId` | Use `viewModel.tabId` directly as the key; delete switch/case |

### 3.7 `layout.dart`

| Current | Target |
|---|---|
| `_resolveTabLabel` with hardcoded fallbacks | Read `props.label` from layout config; fallback to `tabId` (already correct after loading) |
| `dynamicAttributes` parsed from `_parsedLayout!['attributes']` | Also parse `sections` and `viewTypeConfigs`, pass them down |

### 3.8 New: `icon_mapper.dart` (shared service)

```dart
class IconMapper {
  static const Map<String, IconData> _materialIcons = {
    'bar_chart': Icons.bar_chart,
    'location_on': Icons.location_on,
    'dns': Icons.dns,
    'play_arrow': Icons.play_arrow,
    'album': Icons.album,
    'link': Icons.link,
    'folder': Icons.folder,
    'folder_open': Icons.folder_open,
    'insert_drive_file': Icons.insert_drive_file,
    'timer': Icons.timer,
    'monitoring': Icons.monitoring,
    'settings': Icons.settings,
    'security': Icons.security,
    'storage': Icons.storage,
    'network': Icons.network,
    // ... extend as needed
  };

  static IconData resolve(String? iconName) {
    if (iconName == null) return Icons.insert_drive_file;
    return _materialIcons[iconName] ?? Icons.insert_drive_file;
  }
}
```

### 3.9 New: `section_definition.dart` (model)

```dart
class SectionDefinition {
  final String id;
  final String label;
  final int order;
  final List<String> activeWhen;

  const SectionDefinition({
    required this.id,
    required this.label,
    required this.order,
    this.activeWhen = const [],
  });

  factory SectionDefinition.fromJson(Map<String, dynamic> json) {
    return SectionDefinition(
      id: json['id'] as String,
      label: json['label'] as String,
      order: json['order'] as int? ?? 0,
      activeWhen: (json['activeWhen'] as List<dynamic>?)
              ?.map((e) => e as String).toList() ??
          [],
    );
  }
}
```

### 3.10 Updated `AttributeDefinition` (model)

Add fields:

```dart
class AttributeDefinition {
  // Existing fields...
  final String? pairedWith;
  final Map<String, dynamic>? inputFormatters;
  final List<OptionDefinition>? options;  // replaces List<String>?
}

class OptionDefinition {
  final String value;
  final String displayName;
}
```

---

## 4. Generic Section Display Logic

### Problem

The current code (`property_grid.dart:301-303`) hardcodes which sections are active:

```dart
final bool isActive = (group == _sectionLocation && (widget.activeView == _sectionLocation || widget.activeView == _viewIngestion)) ||
                     (group == _sectionAlternate && widget.activeView != _sectionLocation && widget.activeView != _viewIngestion) ||
                     (group != _sectionLocation && group != _sectionAlternate && widget.activeView == group);
```

This cannot handle new sections with new active-view rules.

### Algorithm

Replace with a function that works for any set of sections and any view:

```
function isSectionActive(section, currentView):
    // Rule 1: If section.activeWhen is empty, only activate when
    //         currentView == section.id
    if section.activeWhen is empty:
        return currentView == section.id

    // Rule 2: If section.activeWhen is non-empty, activate when
    //         currentView is in section.activeWhen OR any ancestor
    //         of currentView (based on hierarchy) is in section.activeWhen
    return isCurrentViewOrAncestorIn(currentView, section.activeWhen)
```

Implementation in Dart:

```dart
/// Returns `true` if [section] should appear active given [currentView].
///
/// A section is active if:
///   - Its `activeWhen` list contains [currentView] OR any ancestor view ID
///     (discovered by walking up the hierarchy tree).
///   - If `activeWhen` is empty, only activates when [currentView] == section.id.
bool isSectionActive(
  SectionDefinition section,
  String currentView,
  Map<String, List<String>> ancestorMap,
) {
  if (section.activeWhen.isEmpty) {
    return currentView == section.id;
  }
  if (section.activeWhen.contains(currentView)) return true;

  // Check ancestor chain
  final ancestors = ancestorMap[currentView] ?? [];
  for (final ancestor in ancestors) {
    if (section.activeWhen.contains(ancestor)) return true;
  }
  return false;
}
```

The `ancestorMap` is built once from the hierarchy tree by walking parent-child relationships.

### Section Ordering

```dart
sections.sort((a, b) => a.order.compareTo(b.order));
```

No more `if (a == _sectionLocation) return -1` — sections are ordered purely by their `order` field.

---

## 5. Icon Mapping Scheme

### Approach: Named Material Icon Strings

Every Flutter Material icon has a name (e.g. `Icons.bar_chart` → `"bar_chart"`). We maintain a static `Map<String, IconData>` in a shared `IconMapper` class.

```dart
class IconMapper {
  static const Map<String, IconData> _icons = {
    'bar_chart': Icons.bar_chart,
    'location_on': Icons.location_on,
    'dns': Icons.dns,
    'play_arrow': Icons.play_arrow,
    'album': Icons.album,
    'link': Icons.link,
    'folder': Icons.folder,
    'folder_open': Icons.folder_open,
    'insert_drive_file': Icons.insert_drive_file,
    'timer': Icons.timer,
    'monitoring': Icons.monitoring_,
    'settings': Icons.settings,
    'security': Icons.security,
    'storage': Icons.storage,
    'network': Icons.lan,
  };

  static IconData resolve(String? iconName, {IconData fallback = Icons.insert_drive_file}) {
    if (iconName == null) return fallback;
    return _icons[iconName] ?? fallback;
  }
}
```

**Conventions for icon names in JSON:**
- Use the snake_case name from `Icons.xxx` (e.g. `Icons.location_on` → `"location_on"`)
- For reserved words, use trailing underscore if needed (e.g. `Icons.switch_` → `"switch_"`)
- The mapper is a single source of truth that every widget imports

**Fallback chain:**
1. Hierarchy node's `icon` field → `IconMapper.resolve()`
2. If `icon` is null, use `viewTypeConfigs[node.type].defaultIcon`
3. If still null, use `Icons.insert_drive_file`

---

## 6. Migration Strategy

### Phase 1: Schema Extension (no behavioral changes)

1. Add new fields to `logical-layout.json`:
   - `icon` and `type` to hierarchy nodes
   - `sectionLabel`, `sectionOrder`, `pairedWith`, `inputFormatters`, `options[].displayName` to attributes
   - `sections` array
   - `viewTypeConfigs` object
2. Add `SectionDefinition` model class
3. Add `OptionDefinition` model class  
4. Extend `TreeNode` with `icon` and `type` fields
5. Extend `AttributeDefinition` with new optional fields
6. Update `layout_parser.dart` to parse new fields
7. **All existing defaults remain in place** — widgets still use old hardcoded paths.

**Test:** App runs identically; JSON validates with the new fields present.

### Phase 2: Icon Mapper (tree node icons become dynamic)

1. Create `IconMapper` shared service
2. Update `tree_node_widget.dart` to use `IconMapper.resolve(node.icon)` instead of switch/case
3. Remove the hardcoded switch/case
4. Pass `icon` values in the JSON
5. **Test:** Each tree node renders the correct icon from JSON. If `icon` is missing/null, falls back to `Icons.insert_drive_file`.

### Phase 3: Section Metadata (property grid sections become dynamic)

1. Pass parsed `sections` into `PropertyGrid`
2. Replace hardcoded section titles with `section.label`
3. Replace hardcoded sort logic with `section.order`
4. Implement generic `isSectionActive()` function (see §4)
5. Remove `_sectionLocation`, `_sectionAlternate` constants and all if/else
6. **Test:** Sections render with correct titles, in correct order, with correct active/inactive state — for both old views and new views defined only in JSON.

### Phase 4: Attribute Validation (property_defaults.dart deletion)

1. Validation already works for `minValue`, `maxValue`, `regexPattern`, `isRequired` (code exists in `_validateField`)
2. Remove `widget.validator` default — delete `defaultValidator` from `property_defaults.dart`
3. Remove `widget.shouldPair` default — implement pairing from `pairedWith` attribute field
4. Remove `widget.optionDisplayNames` default — read display names from `options[].displayName`
5. Remove `widget.fallbackInitialValues` default — use `attr.defaultValue`
6. Remove `_keyCountryCode` hardcoded formatter — implement via `inputFormatters` metadata
7. **Delete `property_defaults.dart`** entirely
8. **Test:** All existing validations (range, required, regex, pairing, enum display) work from JSON alone.

### Phase 5: Topology Status Colors

1. Parse `viewTypeConfigs` in layout
2. For each topology node, look up its type's `topologyStatusColors` map
3. Replace hardcoded `activeStatusColor`/`warningStatusColor` with dynamic lookup
4. **Test:** Topology node colors match the JSON configuration.

### Phase 6: Cleanup

1. Remove `table_view_widget.dart` hardcoded switch/case
2. Remove `layout.dart` hardcoded tab label fallbacks
3. Remove any remaining `_typeDouble`/`_typeInt`/`_typeEnum` constants (use `attr.type` directly)
4. **Test:** Full regression — no hardcoded display data remains.

---

## 7. Risk Assessment

### 7.1 Breakage Risks

| Risk | Impact | Mitigation |
|---|---|---|
| `icon` field missing from existing hierarchy nodes | Tree nodes display fallback icon | Phase 2 — `IconMapper.resolve()` uses `Icons.insert_drive_file` fallback. Also accept `Icons.folder`/`Icons.folder_open` for parent nodes. |
| `sections` array absent from JSON | Property grid shows no sections | Default to grouping attributes by `sectionGroup` alphabetically if no `sections` data. Old behavior preserved. |
| `activeWhen` field missing from section | All sections appear inactive | Default `activeWhen` to `[section.id]` if absent; or treat empty as "match any view". |
| `section.label` missing | Section shows `section.id + " Section"` fallback | Same as current behavior. |
| `viewTypeConfigs` missing | Topology colors fall back to defaults | `TopologyPainterColors` keeps existing fixed colors as default. |
| `pairedWith` attribute points to nonexistent key | Pairing silently ignored | Validate at parse time; log warning, skip invalid pairs. |
| Enum `options` use old string-only format | Crash at fromJson | Accept both formats: `["a", "b"]` (old) and `[{"value": "a", "displayName": "A"}]` (new). |
| New object type added to JSON without corresponding `type` in `viewTypeConfigs` | Topology colors use default | Use a global default color map as fallback. |
| `regexPattern` is invalid regex | Crash on field validation | Wrap `RegExp` creation in try-catch; treat unparseable patterns as no constraint. |
| `inputFormatters` uses unknown formatter name | Formatter silently skipped | Log warning + skip. |

### 7.2 Backward Compatibility Strategy

- All new JSON fields are **optional**.
- The app loads the `meta.version` field; if `version` is `"1.0.0"`, run in strict backward-compatible mode (use all old hardcoded defaults).
- Each widget reads its metadata and falls back to the old behavior when the metadata is absent.
- Phase-by-phase rollout means each change is independently testable — the app never enters a state where it depends on metadata that hasn't been deployed yet.

### 7.3 Performance Considerations

- Parsing the full JSON once at startup is negligible (< 100KB).
- `IconMapper` is a static const map — zero allocation.
- `isSectionActive` with ancestor lookup is O(depth) per section, trivially fast.
- Validation is already per-blur — no change needed.

### 7.4 Data Consistency Guarantee

The `meta.version` field in `logical-layout.json` must be bumped to `"2.0.0"` when the new schema is rolled out. A version compatibility check at startup ensures the app does not attempt to use v2 features with a v1 JSON (or vice versa). Schema migration documentation belongs in `docs/architecture/layout-schema.md`.
