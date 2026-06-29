import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

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
  Future<TypeDescriptor?> typeFor(String typeName) async =>
      (await discoverTypes()).firstWhere((t) => t.typeName == typeName);

  @override
  Future<List<(String, String)>> discoverHierarchy() async => [];
}
