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
  Future<List<(String, String)>> discoverHierarchy() async => [];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield {};
  }
}
