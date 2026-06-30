import 'package:app_flutter/domain/column_model.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDataSource implements DataSource {
  @override
  String get name => 'mock';

  Future<TypeDescriptor?> Function(String typeName)? onTypeFor;
  Future<List<Map<String, dynamic>>> Function(String parentNodeId)?
      onFetchElements;
  Future<List<Map<String, dynamic>>> Function(String parentNodeId)?
      onFetchAlarms;
  Future<List<Map<String, dynamic>>> Function(String parentNodeId)?
      onFetchEvents;

  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [];

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async =>
      onTypeFor?.call(typeName) ?? null;

  @override
  Future<List<(String, String)>> discoverHierarchy() async => [];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) =>
      const Stream.empty();

  @override
  Future<List<Map<String, dynamic>>> fetchElements(
          String parentNodeId) async =>
      onFetchElements?.call(parentNodeId) ?? [];

  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(
          String parentNodeId) async =>
      onFetchAlarms?.call(parentNodeId) ?? [];

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(
          String parentNodeId) async =>
      onFetchEvents?.call(parentNodeId) ?? [];
}

void main() {
  group('TablesViewModel columnModels', () {
    late _MockDataSource dataSource;
    late TablesViewModel viewModel;

    setUp(() {
      dataSource = _MockDataSource();
      viewModel = TablesViewModel(dataSource, 'test');
    });

    test('columnModels is empty before load', () {
      expect(viewModel.columnModels, isEmpty);
    });

    test('columnModels count matches FieldDescriptor count', () async {
      final fields = [
        FieldDescriptor(key: 'k1', label: 'Col 1', type: 'string'),
        FieldDescriptor(key: 'k2', label: 'Col 2', type: 'int'),
        FieldDescriptor(key: 'k3', label: 'Col 3', type: 'double'),
      ];

      dataSource.onTypeFor = (typeName) async {
        if (typeName == 'root') {
          return TypeDescriptor(
            typeName: 'root',
            displayName: 'Root',
            iconName: 'folder',
            fields: [],
            childTypes: [],
            relatedTypes: [
              TypeRelationDescriptor(
                relationName: 'has',
                childTypeName: 'ChildType',
                childLabel: 'Child Label',
              ),
            ],
            parentTypes: [],
          );
        }
        if (typeName == 'ChildType') {
          return TypeDescriptor(
            typeName: 'ChildType',
            displayName: 'Child',
            iconName: 'child',
            fields: fields,
            childTypes: [],
            relatedTypes: [],
            parentTypes: [],
          );
        }
        return null;
      };

      dataSource.onFetchElements = (parentNodeId) async => [
        {'k1': 'a', 'k2': '1', 'k3': '1.0'},
      ];

      await viewModel.loadForNode('root');
      expect(viewModel.columnModels.length, fields.length);
    });

    test('columnModels is populated correctly in _loadData', () async {
      final fields = [
        FieldDescriptor(key: 'voltage', label: 'Voltage (V)', type: 'double'),
        FieldDescriptor(key: 'current', label: 'Current (A)', type: 'double'),
      ];

      dataSource.onTypeFor = (typeName) async {
        if (typeName == 'root') {
          return TypeDescriptor(
            typeName: 'root',
            displayName: 'Root',
            iconName: 'folder',
            fields: [],
            childTypes: [],
            relatedTypes: [
              TypeRelationDescriptor(
                relationName: 'has',
                childTypeName: 'ChildType',
                childLabel: 'Child Label',
              ),
            ],
            parentTypes: [],
          );
        }
        if (typeName == 'ChildType') {
          return TypeDescriptor(
            typeName: 'ChildType',
            displayName: 'Child',
            iconName: 'child',
            fields: fields,
            childTypes: [],
            relatedTypes: [],
            parentTypes: [],
          );
        }
        return null;
      };

      dataSource.onFetchElements = (parentNodeId) async => [
        {'voltage': '230', 'current': '10'},
      ];

      await viewModel.loadForNode('root');

      expect(viewModel.columnModels.length, 2);
      expect(viewModel.columnModels[0].key, 'voltage');
      expect(viewModel.columnModels[0].label, 'Voltage (V)');
      expect(viewModel.columnModels[0].type, 'double');
      expect(viewModel.columnModels[1].key, 'current');
      expect(viewModel.columnModels[1].label, 'Current (A)');
      expect(viewModel.columnModels[1].type, 'double');
    });

    test('columnModels is cleared on error', () async {
      dataSource.onTypeFor = (typeName) async {
        if (typeName == 'root') {
          return TypeDescriptor(
            typeName: 'root',
            displayName: 'Root',
            iconName: 'folder',
            fields: [],
            childTypes: [
              TypeRelationDescriptor(
                relationName: 'contains',
                childTypeName: 'ChildType',
                childLabel: 'Child Type',
              ),
            ],
            relatedTypes: [],
            parentTypes: [],
          );
        }
        if (typeName == 'ChildType') {
          return TypeDescriptor(
            typeName: 'ChildType',
            displayName: 'Child',
            iconName: 'child',
            fields: [
              FieldDescriptor(key: 'k1', label: 'Col 1', type: 'string'),
            ],
            childTypes: [],
            relatedTypes: [],
            parentTypes: [],
          );
        }
        return null;
      };

      dataSource.onFetchElements = (parentNodeId) async =>
          throw Exception('fetch failed');

      await viewModel.loadForNode('root');
      expect(viewModel.columnModels, isEmpty);
    });
  });
}
