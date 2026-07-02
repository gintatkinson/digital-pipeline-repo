import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pipeline_app/domain/data_source.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

/// Firestore-backed [DataSource] using collections for each entity.
///
/// Maps five Firestore collections to the domain tables:
/// `type_definition`, `type_attribute`, `type_relation`,
/// `instance`, `child_entry`. All queries use [FirebaseFirestore].
class FirebaseDataSource implements DataSource {
  final FirebaseFirestore _firestore;

  FirebaseDataSource(this._firestore);

  @override
  String get name => 'firebase';

  @override
  void close() {}

  FieldType _parseType(String raw) {
    switch (raw) {
      case 'string': return FieldType.string;
      case 'int_': return FieldType.int_;
      case 'double_': return FieldType.double_;
      case 'enum_': return FieldType.enum_;
      case 'date': return FieldType.date;
      case 'bool_': return FieldType.bool_;
      default: return FieldType.string;
    }
  }

  List<String>? _listFrom(dynamic value) {
    if (value is List) return value.cast<String>();
    return null;
  }

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final typeSnap = await _firestore.collection('type_definition').get();
    final descriptors = <TypeDescriptor>[];
    for (final doc in typeSnap.docs) {
      descriptors.add(await _buildType(doc));
    }
    return descriptors;
  }

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final doc = await _firestore.collection('type_definition').doc(typeName).get();
    if (!doc.exists) return null;
    return _buildType(doc);
  }

  Future<TypeDescriptor> _buildType(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final typeName = doc.id;

    final attrSnap = await _firestore
        .collection('type_attribute')
        .where('type_name', isEqualTo: typeName)
        .get();
    final fields = attrSnap.docs.map((a) {
      final d = a.data();
      final ft = _parseType(d['attr_type'] as String);
      return FieldDescriptor(
        key: d['attr_key'] as String,
        label: d['label'] as String,
        type: ft,
        sectionLabel: d['section_label'] as String?,
        sectionOrder: d['section_order'] as int? ?? 0,
        required: d['is_required'] == true || d['is_required'] == 1,
        minValue: d['min_value'] as num?,
        maxValue: d['max_value'] as num?,
        pattern: d['pattern'] as String?,
        enumOptions: _listFrom(d['enum_options']),
        enumDisplayNames: _listFrom(d['enum_display_names']),
        defaultValue: d['default_value'],
        inputFormatters: _listFrom(d['input_formatters']),
      );
    }).toList();

    final relSnap = await _firestore
        .collection('type_relation')
        .where('parent_type_name', isEqualTo: typeName)
        .get();
    final childTypes = relSnap.docs.map((r) {
      final d = r.data();
      return TypeRelationDescriptor(
        relationName: d['relation_name'] as String,
        targetTypeName: d['child_type_name'] as String,
        displayLabel: d['child_label'] as String,
      );
    }).toList();

    return TypeDescriptor(
      typeName: typeName,
      displayName: data['display_name'] as String,
      iconName: data['icon_name'] as String,
      fields: fields,
      childTypes: childTypes,
    );
  }

  @override
  Future<List<InstanceDescriptor>> discoverInstances() async {
    final snap = await _firestore.collection('instance').get();
    final typeSnap = await _firestore.collection('type_definition').get();
    final displayNames = <String, String>{};
    for (final doc in typeSnap.docs) {
      final d = doc.data();
      displayNames[doc.id] = d['display_name'] as String;
    }
    return snap.docs.map((doc) {
      final nodeId = doc.id;
      final lastDash = nodeId.lastIndexOf('-');
      final typeName = lastDash > 0 ? nodeId.substring(0, lastDash) : nodeId;
      final displayName = displayNames[typeName] ?? typeName;
      return InstanceDescriptor(
        nodeId: nodeId,
        typeName: typeName,
        displayLabel: '$displayName $nodeId',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> fetchProperties(String nodeId) async {
    final doc = await _firestore.collection('instance').doc(nodeId).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data.remove('__doc_id');
    return data;
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    await _firestore.collection('instance').doc(nodeId).set(data, SetOptions(merge: true));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChildren(
    String nodeId,
    String relationName,
  ) async {
    final snap = await _firestore
        .collection('child_entry')
        .where('parent_node_id', isEqualTo: nodeId)
        .where('relation_name', isEqualTo: relationName)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }
}
