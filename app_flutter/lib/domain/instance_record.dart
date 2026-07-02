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
    return InstanceRecord(
      id: map['id']?.toString() ?? '',
      parentNodeId: map['parent_node_id']?.toString() ?? '',
      typeName: typeName,
      attributes: map,
    );
  }
}
