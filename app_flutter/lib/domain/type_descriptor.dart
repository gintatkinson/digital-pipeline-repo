/// Describes a single object type known to the connected data source.
///
/// The client uses this to render tree nodes, property forms, table columns,
/// and topology graphs. Everything is discovered at runtime — the class itself
/// knows nothing about specific domains like telco or air traffic control.
///
/// One [TypeDescriptor] instance exists per object type, not per instance.
class TypeDescriptor {
  /// Internal identifier matching the data source, e.g. "device".
  final String typeName;

  /// Human-readable label for UI display, e.g. "Device".
  final String displayName;

  /// Material icon name string, e.g. "developer_board". Resolved to [IconData] by [IconMapper].
  final String iconName;

  /// All editable fields/attributes of this type.
  final List<FieldDescriptor> fields;

  /// Child object types (for tree hierarchy and tab tables).
  final List<TypeRelationDescriptor> childTypes;

  /// Parent object types (for reverse tree navigation).
  final List<TypeRelationDescriptor> parentTypes;

  const TypeDescriptor({
    required this.typeName,
    required this.displayName,
    required this.iconName,
    required this.fields,
    required this.childTypes,
    required this.parentTypes,
  });
}

/// Describes one field/attribute of a [TypeDescriptor].
class FieldDescriptor {
  /// Unique key within the type, e.g. "maxVoltage".
  final String key;

  /// Human-readable label, e.g. "Max Voltage (V)".
  final String label;

  /// Data type: "string", "int", "double", "enum", "date".
  final String type;

  /// UI section grouping label, e.g. "Alternate Structural Grid Frame".
  /// If null, the field belongs to a default "Other" section.
  final String? sectionLabel;

  /// Display order within the section (lower = first).
  final int sectionOrder;

  /// Whether this field must have a non-null value.
  final bool required;

  /// Minimum numeric value (for int/double types).
  final num? minValue;

  /// Maximum numeric value (for int/double types).
  final num? maxValue;

  /// Regex pattern for string validation.
  final String? pattern;

  /// Allowed enum values (for enum types).
  final List<String>? enumOptions;

  /// Display names for each enum option (same index as [enumOptions]).
  final List<String>? enumDisplayNames;

  /// Default value when creating a new instance.
  final dynamic defaultValue;

  /// Input formatter names, e.g. ["uppercase", "maxLength:2"].
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

/// Describes a relationship between two [TypeDescriptor]s.
class TypeRelationDescriptor {
  /// Semantic name of the relation, e.g. "contains", "belongs_to".
  final String relationName;

  /// The [TypeDescriptor.typeName] of the related type.
  final String childTypeName;

  /// Human-readable plural label for UI tab headers, e.g. "Sensors".
  final String childLabel;

  const TypeRelationDescriptor({
    required this.relationName,
    required this.childTypeName,
    required this.childLabel,
  });
}
