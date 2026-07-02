/// Value types for [FieldDescriptor] instances.
///
/// Each variant maps to a corresponding SQLite column type and Flutter
/// form widget: [string] → TextFormField, [int_] → integer input,
/// [double_] → decimal input, [enum_] → dropdown, [date] → date picker,
/// [bool_] → switch/checkbox.
enum FieldType { string, int_, double_, enum_, date, bool_ }

/// Describes a single attribute of a [TypeDescriptor].
///
/// Carries validation constraints (min/max, pattern, enum options) and
/// display metadata (section grouping, label). Used by [PropertyGrid] to
/// render form fields and by [SeedConfig] to generate test data.
///
/// [key] is the formula-derived attribute identifier (e.g. `attr_01`).
/// [sectionLabel] groups fields into visual sections; `null` fields
/// render without a section header.
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

  const FieldDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.sectionLabel,
    this.sectionOrder = 0,
    this.required = false,
    this.minValue,
    this.maxValue,
    this.pattern,
    this.enumOptions,
    this.enumDisplayNames,
    this.defaultValue,
    this.inputFormatters,
  });
}

/// Links a parent type to a child type via a named relation.
///
/// [relationName] is the formula-derived relation key
/// (e.g. `relates_to_Type1`). [targetTypeName] identifies the child
/// type. [displayLabel] provides a human-readable tab header for the
/// [TablePanel].
class TypeRelationDescriptor {
  final String relationName;
  final String targetTypeName;
  final String displayLabel;

  const TypeRelationDescriptor({
    required this.relationName,
    required this.targetTypeName,
    required this.displayLabel,
  });
}

/// Schema definition for a domain entity type.
///
/// Discovered at runtime from the data source. Carries [fields] (the
/// attribute schema), [childTypes] (outgoing relations), and
/// [parentTypes] (incoming relations). [iconName] maps to a Material
/// icon via [IconMapper].
///
/// [typeName] is the formula-derived type identifier (e.g. `Type0`).
class TypeDescriptor {
  final String typeName;
  final String displayName;
  final String iconName;
  final List<FieldDescriptor> fields;
  final List<TypeRelationDescriptor> childTypes;
  final List<TypeRelationDescriptor> parentTypes;

  const TypeDescriptor({
    required this.typeName,
    required this.displayName,
    required this.iconName,
    this.fields = const [],
    this.childTypes = const [],
    this.parentTypes = const [],
  });
}

/// A concrete node in the instance tree, surfaced in the sidebar.
///
/// [nodeId] is the formula-derived identifier (e.g. `Type0-000`).
/// [typeName] is the parent type (e.g. `Type0`). [displayLabel]
/// combines type display name with the instance suffix for the UI.
class InstanceDescriptor {
  final String nodeId;
  final String typeName;
  final String displayLabel;

  const InstanceDescriptor({
    required this.nodeId,
    required this.typeName,
    required this.displayLabel,
  });
}
