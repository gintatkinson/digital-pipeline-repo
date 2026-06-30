import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

class MockDataSource extends DataSource {
  @override
  Future<String> resolveLabel(String typeName, String id) async {
    return 'Label for $id ($typeName)';
  }

  @override
  String get name => 'mock';

  @override
  Future<List<TypeDescriptor>> discoverTypes() async => [];

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async => null;

  @override
  Future<List<(String, String)>> discoverHierarchy() async => [];

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) => const Stream.empty();

  @override
  Future<List<Map<String, dynamic>>> fetchElements(String nodeId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String nodeId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String nodeId) async => [];
}

void main() {
  group('DataSource', () {
    test('resolveLabel returns label for given type and id', () async {
      final ds = MockDataSource();
      final label = await ds.resolveLabel('device', 'dev-123');
      expect(label, equals('Label for dev-123 (device)'));
    });
  });
}
