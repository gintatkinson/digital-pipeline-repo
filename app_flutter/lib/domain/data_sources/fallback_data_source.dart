import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Fallback [DataSource] used when the pre-built database has no
/// metadata tables or when Firestore is unavailable.
///
/// Provides a minimal single-type ontology (Item, SubElement, Alarm,
/// Event) so the app is usable without any domain configuration.
/// Replace with [SqliteDataSource] or a custom [DataSource] for
/// production deployments. This data source is read-only — calls to
/// [saveProperties] are no-ops, and [watchProperties] always yields
/// an empty map. Generated data (elements, alarms, events) is
/// deterministic and scoped to the "Item" parent node.
class FallbackDataSource implements DataSource {
  @override
  String get name => 'fallback';

  /// Returns a hardcoded list of four [TypeDescriptor]s: Item,
  /// SubElement, Alarm, and Event.
  ///
  /// Always succeeds with the same result regardless of state — no
  /// external dependencies. Use this to render the full UI tree when
  /// no real data source is configured. The Item type defines a
  /// "contains" relation to SubElement and "affects"/"records"
  /// relations to Alarm/Event respectively.
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

  /// Searches the hardcoded type list for a [TypeDescriptor] whose
  /// [TypeDescriptor.typeName] matches [typeName].
  ///
  /// Returns `null` when [typeName] is not one of the four hardcoded
  /// types ("Item", "SubElement", "Alarm", "Event"). Uses
  /// `firstWhere` internally and catches [StateError] gracefully.
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    try {
      return (await discoverTypes()).firstWhere((t) => t.typeName == typeName);
    } catch (_) {
      return null;
    }
  }

  /// Returns an empty list — no hierarchy is defined in the fallback.
  @override
  Future<List<(String, String)>> discoverHierarchy() async => [];

  /// Always returns an empty map — no persistent storage is available.
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  /// No-op — the fallback data source does not persist data.
  ///
  /// STATE CHANGE: None. [data] is silently discarded. Callers should
  /// be aware that saves are not durable and will be lost on refresh.
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  /// Returns a broadcast stream that immediately yields an empty map
  /// and never emits further values.
  ///
  /// The stream never closes — subscribers that do not cancel will
  /// remain alive indefinitely. Cancel the subscription to avoid leaks.
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

  /// Filters the hardcoded `_elements` list for rows whose
  /// `parent_node_id` equals [parentNodeId].
  ///
  /// Returns an empty list when no elements match (e.g. for any
  /// parent other than "Item"). Only 15 deterministic elements are
  /// available, all scoped to "Item".
  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async =>
      _elements.where((e) => e['parent_node_id'] == parentNodeId).toList();

  /// Filters the hardcoded `_alarms` list for rows whose
  /// `parent_node_id` equals [parentNodeId].
  ///
  /// Returns an empty list when no alarms match. Only 15
  /// deterministic alarms are available, all scoped to "Item".
  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async =>
      _alarms.where((e) => e['parent_node_id'] == parentNodeId).toList();

  /// Filters the hardcoded `_events` list for rows whose
  /// `parent_node_id` equals [parentNodeId].
  ///
  /// Returns an empty list when no events match. Only 15
  /// deterministic events are available, all scoped to "Item".
  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async =>
      _events.where((e) => e['parent_node_id'] == parentNodeId).toList();
}
