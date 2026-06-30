import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// A [DataSource] implementation backed by Cloud Firestore.
///
/// Type schemas are stored in the `schema` collection (`types` and `hierarchy`
/// documents). Instance data lives in the `data` collection, while elements,
/// alarms, and events are stored in their own collections indexed by
/// `parent_node_id`. Property changes are broadcast via an in-memory
/// [StreamController] so that all watchers see live updates.
class FirebaseDataSource implements DataSource {
  /// Creates a [FirebaseDataSource] connected to the given [Firestore] instance.
  FirebaseDataSource(this._firestore);
  final FirebaseFirestore _firestore;
  final StreamController<Map<String, dynamic>> _propertiesController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  String get name => 'firebase';

  /// Fetches all type descriptors from the `schema/types` Firestore document.
  ///
  /// Returns an empty list if the document does not exist or has no `fields`
  /// entry. Each field entry is parsed into a [TypeDescriptor] including its
  /// display name, icon, fields, and relation descriptors.
  ///
  /// Throws a [FirebaseException] if the underlying Firestore read fails.
  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final snapshot = await _firestore.collection('schema').doc('types').get();
    final data = snapshot.data();
    if (data == null) return [];
    final fields = data['fields'] as Map<String, dynamic>? ?? {};
    final types = <TypeDescriptor>[];
    for (final entry in fields.entries) {
      final typeName = entry.key;
      final def = entry.value as Map<String, dynamic>;
      types.add(TypeDescriptor(
        typeName: typeName,
        displayName: def['displayName'] as String? ?? typeName,
        iconName: def['iconName'] as String? ?? 'insert_drive_file',
        fields: _parseFields(def['fields'] as List<dynamic>?),
        childTypes: _parseRelations(def['childTypes'] as List<dynamic>?),
        relatedTypes: _parseRelations(def['relatedTypes'] as List<dynamic>?),
        parentTypes: _parseRelations(def['parentTypes'] as List<dynamic>?),
      ));
    }
    return types;
  }

  /// Returns the [TypeDescriptor] whose [TypeDescriptor.typeName] matches
  /// [typeName], or `null` if no such type exists in the data source.
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final types = await discoverTypes();
    for (final t in types) {
      if (t.typeName == typeName) return t;
    }
    return null;
  }

  /// Reads the `schema/hierarchy` Firestore document and returns parent-child
  /// type pairs `(parentTypeName, childTypeName)`.
  ///
  /// Returns an empty list if the document is missing or has no `pairs` field.
  @override
  Future<List<(String, String)>> discoverHierarchy() async {
    final snapshot = await _firestore.collection('schema').doc('hierarchy').get();
    final data = snapshot.data();
    if (data == null) return [];
    final pairs = data['pairs'] as List<dynamic>? ?? [];
    return pairs.map((p) {
      final pair = p as List<dynamic>;
      return (pair[0] as String, pair[1] as String);
    }).toList();
  }

  /// Fetches the property map for the node identified by [nodeId] from the
  /// `data` Firestore collection.
  ///
  /// Returns an empty map if the document does not exist.
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    final doc = await _firestore.collection('data').doc(nodeId).get();
    final data = doc.data();
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  /// Persists [data] as the properties for [nodeId] in the `data` Firestore
  /// collection using a deep merge. After saving, a change event is broadcast
  /// to all active [watchProperties] subscribers.
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    await _firestore.collection('data').doc(nodeId).set(data, SetOptions(merge: true));
    _propertiesController.add({'nodeId': nodeId, 'data': data});
  }

  /// Returns a broadcast stream that first emits the current properties for
  /// [nodeId], then yields subsequent updates whenever [saveProperties] is
  /// called for the same [nodeId].
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield await fetchProperties(nodeId);
    await for (final event in _propertiesController.stream) {
      if (event['nodeId'] == nodeId) {
        yield event['data'] as Map<String, dynamic>;
      }
    }
  }

  /// Queries the `elements` Firestore collection for all documents whose
  /// `parent_node_id` equals [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async {
    final snapshot = await _firestore
        .collection('elements')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  /// Queries the `alarms` Firestore collection for all documents whose
  /// `parent_node_id` equals [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async {
    final snapshot = await _firestore
        .collection('alarms')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  /// Queries the `events` Firestore collection for all documents whose
  /// `parent_node_id` equals [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async {
    final snapshot = await _firestore
        .collection('events')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  List<FieldDescriptor> _parseFields(List<dynamic>? fields) {
    if (fields == null) return [];
    return fields.map((f) {
      final map = f as Map<String, dynamic>;
      return FieldDescriptor(
        key: map['key'] as String,
        label: map['label'] as String,
        type: map['type'] as String,
        sectionLabel: map['sectionLabel'] as String?,
        sectionOrder: map['sectionOrder'] as int? ?? 0,
        required: map['required'] as bool? ?? false,
        minValue: map['minValue'] as num?,
        maxValue: map['maxValue'] as num?,
        pattern: map['pattern'] as String?,
        enumOptions: map['enumOptions'] != null
            ? List<String>.from(map['enumOptions'] as List)
            : null,
        enumDisplayNames: map['enumDisplayNames'] != null
            ? List<String>.from(map['enumDisplayNames'] as List)
            : null,
        defaultValue: map['defaultValue'],
        inputFormatters: map['inputFormatters'] != null
            ? List<String>.from(map['inputFormatters'] as List)
            : null,
      );
    }).toList();
  }

  List<TypeRelationDescriptor> _parseRelations(List<dynamic>? relations) {
    if (relations == null) return [];
    return relations.map((r) {
      final map = r as Map<String, dynamic>;
      return TypeRelationDescriptor(
        relationName: map['relationName'] as String,
        childTypeName: map['childTypeName'] as String,
        childLabel: map['childLabel'] as String,
      );
    }).toList();
  }
}
