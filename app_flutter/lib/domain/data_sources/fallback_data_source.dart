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
      ],
      relatedTypes: [
        TypeRelationDescriptor(relationName: 'affects', childTypeName: 'Alarm', childLabel: 'Alarms'),
        TypeRelationDescriptor(relationName: 'records', childTypeName: 'Event', childLabel: 'Events'),
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
      relatedTypes: [],
      parentTypes: [TypeRelationDescriptor(relationName: 'contains', childTypeName: 'Item', childLabel: 'Item')],
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
      relatedTypes: [],
      parentTypes: [TypeRelationDescriptor(relationName: 'contains', childTypeName: 'Item', childLabel: 'Item')],
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
      relatedTypes: [],
      parentTypes: [TypeRelationDescriptor(relationName: 'contains', childTypeName: 'Item', childLabel: 'Item')],
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
  Future<List<(String, String)>> discoverHierarchy() async => [];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }

  final List<Map<String, dynamic>> _elements = List.generate(15, (i) => {
    'id': 'elem-${i + 1}',
    'parent_node_id': 'Item',
    'name': 'Element ${i + 1}',
    'type': ['Worker', 'Collector', 'Sensor'][i % 3],
    'status': ['Active', 'Standby', 'Error'][i % 3],
  });

  final List<Map<String, dynamic>> _alarms = List.generate(15, (i) => {
    'id': 'alarm-${i + 1}',
    'parent_node_id': 'Item',
    'target': 'Target ${i + 1}',
    'severity': ['Critical', 'Warning', 'Info'][i % 3],
    'timestamp': '2026-06-${(i % 28) + 1}',
  });

  final List<Map<String, dynamic>> _events = List.generate(15, (i) => {
    'id': 'event-${i + 1}',
    'parent_node_id': 'Item',
    'source': ['System', 'User', 'External'][i % 3],
    'message': 'Event ${i + 1} occurred',
    'timestamp': '2026-06-${(i % 28) + 1}',
  });

  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async =>
      _elements.where((e) => e['parent_node_id'] == parentNodeId).toList();

  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async =>
      _alarms.where((e) => e['parent_node_id'] == parentNodeId).toList();

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async =>
      _events.where((e) => e['parent_node_id'] == parentNodeId).toList();
}
