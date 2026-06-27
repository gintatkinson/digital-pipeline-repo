class AttributeDefinition {
  final String key;
  final String label;
  final String type; // 'double' | 'int' | 'string' | 'enum'
  final String sectionGroup;
  final List<String>? options;
  final bool isRequired;
  final String? regexPattern;
  final num? minValue;
  final num? maxValue;

  const AttributeDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.sectionGroup,
    this.options,
    this.isRequired = false,
    this.regexPattern,
    this.minValue,
    this.maxValue,
  });

  factory AttributeDefinition.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    return AttributeDefinition(
      key: json['key'] as String,
      label: json['label'] as String,
      type: typeStr == 'enumeration' ? 'enum' : typeStr,
      sectionGroup: json['sectionGroup'] as String,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isRequired: json['isRequired'] as bool? ?? false,
      regexPattern: json['regexPattern'] as String?,
      minValue: json['minValue'] as num?,
      maxValue: json['maxValue'] as num?,
    );
  }

  dynamic get defaultValue {
    if (type == 'int') {
      return minValue?.toInt() ?? 0;
    } else if (type == 'double') {
      return minValue?.toDouble() ?? 0.0;
    } else if (type == 'enum') {
      if (options != null && options!.isNotEmpty) {
        return options!.first;
      }
      return '';
    } else {
      return '';
    }
  }
}

// TODO(#79): Replace with dynamic DB-backed attribute schema.
// The fromJson factory exists — load from DB/config instead of this const list.
const List<AttributeDefinition> defaultCoordinateAttributes = [
  AttributeDefinition(
    key: 'latitude',
    label: 'Latitude',
    type: 'double',
    sectionGroup: 'Location',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'longitude',
    label: 'Longitude',
    type: 'double',
    sectionGroup: 'Location',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'altitude',
    label: 'Elevation / Altitude (m)',
    type: 'int',
    sectionGroup: 'Location',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'roomName',
    label: 'Room Identifier',
    type: 'string',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'gridRow',
    label: 'Grid Row',
    type: 'int',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'gridColumn',
    label: 'Grid Column',
    type: 'int',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'maxVoltage',
    label: 'Max Voltage (V)',
    type: 'double',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'maxAllocatedPower',
    label: 'Max Allocated Power (W)',
    type: 'double',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'countryCode',
    label: 'Country Code (ISO-2)',
    type: 'string',
    sectionGroup: 'Alternate',
    isRequired: false,
  ),
  AttributeDefinition(
    key: 'locationType',
    label: 'Location Hierarchy Type',
    type: 'enum',
    sectionGroup: 'Alternate',
    options: ['site', 'room', 'building', 'invalid-test-option'],
    isRequired: false,
  ),
];
