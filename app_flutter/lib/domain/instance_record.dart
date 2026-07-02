import 'dart:convert';

class InstanceRecord {
  final String id;
  final String parentNodeId;
  final String typeName;
  final Map<String, dynamic> attributes;

  const InstanceRecord({
    required this.id,
    required this.parentNodeId,
    required this.typeName,
    required this.attributes,
  });

  factory InstanceRecord.fromMap(Map<String, dynamic> map, String typeName) {
    Map<String, dynamic> attrs = {};
    if (map['data_json'] != null) {
      try {
        final decoded = jsonDecode(map['data_json'] as String);
        if (decoded is Map<String, dynamic>) {
          attrs = decoded;
        }
      } catch (_) {}
    } else {
      attrs = Map<String, dynamic>.from(map);
    }
    return InstanceRecord(
      id: map['id']?.toString() ?? attrs['id']?.toString() ?? '',
      parentNodeId: map['parent_node_id']?.toString() ?? attrs['parent_node_id']?.toString() ?? '',
      typeName: map['type_name']?.toString() ?? typeName,
      attributes: attrs,
    );
  }
}
