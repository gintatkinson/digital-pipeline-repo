import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Fallback [DataSource] used when the pre-built database has no metadata tables.
///
/// Provides a minimal single-type ontology so the app is usable without
/// any domain configuration. Replace with SqliteDataSource or a custom
/// DataSource for production deployments.
class FallbackDataSource implements DataSource {
  @override
  String get name => 'fallback';

  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [
    TypeDescriptor(
      typeName: 'Item',
      displayName: 'Item',
      iconName: 'insert_drive_file',
      fields: [
        FieldDescriptor(key: 'name', label: 'Name', type: 'string', required: true, sectionOrder: 0),
        FieldDescriptor(key: 'description', label: 'Description', type: 'string', sectionOrder: 1),
      ],
      childTypes: [
        TypeRelationDescriptor(relationName: 'contains', childTypeName: 'SubElement', childLabel: 'Items'),
        TypeRelationDescriptor(relationName: 'affects', childTypeName: 'Alarm', childLabel: 'Status'),
        TypeRelationDescriptor(relationName: 'records', childTypeName: 'Event', childLabel: 'Activity'),
      ],
      parentTypes: [],
    ),
    TypeDescriptor(
      typeName: 'SubElement',
      displayName: 'Sub Element',
      iconName: 'widgets',
      fields: [
        FieldDescriptor(key: 'id', label: 'ID', type: 'string'),
        FieldDescriptor(key: 'name', label: 'Name', type: 'string'),
        FieldDescriptor(key: 'type', label: 'Type', type: 'string'),
        FieldDescriptor(key: 'status', label: 'Status', type: 'string'),
      ],
      childTypes: [],
      parentTypes: [],
    ),
    TypeDescriptor(
      typeName: 'Alarm',
      displayName: 'Alarm',
      iconName: 'warning',
      fields: [
        FieldDescriptor(key: 'id', label: 'Alarm ID', type: 'string'),
        FieldDescriptor(key: 'target', label: 'Target', type: 'string'),
        FieldDescriptor(key: 'severity', label: 'Severity', type: 'string'),
        FieldDescriptor(key: 'timestamp', label: 'Timestamp', type: 'string'),
      ],
      childTypes: [],
      parentTypes: [],
    ),
    TypeDescriptor(
      typeName: 'Event',
      displayName: 'Event',
      iconName: 'event',
      fields: [
        FieldDescriptor(key: 'id', label: 'Event ID', type: 'string'),
        FieldDescriptor(key: 'source', label: 'Source', type: 'string'),
        FieldDescriptor(key: 'message', label: 'Message', type: 'string'),
        FieldDescriptor(key: 'timestamp', label: 'Timestamp', type: 'string'),
      ],
      childTypes: [],
      parentTypes: [],
    ),
  ];

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    try {
      return (await discoverTypes()).firstWhere((t) => t.typeName == typeName);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<(String, String)>> discoverHierarchy() async => [
    ('Item', 'SubElement'),
    ('Item', 'Alarm'),
    ('Item', 'Event'),
  ];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}
