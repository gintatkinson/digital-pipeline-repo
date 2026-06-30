import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/action_descriptor.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/data_sources/fallback_data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

class _TestDataSource extends DataSource {
  @override String get name => 'test';
  @override Future<List<TypeDescriptor>> discoverTypes() async => [];
  @override Future<TypeDescriptor?> typeFor(String n) async => null;
  @override Future<List<(String, String)>> discoverHierarchy() async => [];
  @override Future<Map<String, dynamic>> fetchProperties(String n) async => {};
  @override Future<void> saveProperties(String n, Map<String, dynamic> d) async {}
  @override Stream<Map<String, dynamic>> watchProperties(String n) async* { yield {}; }
  @override Future<List<Map<String, dynamic>>> fetchElements(String n) async => [];
  @override Future<List<Map<String, dynamic>>> fetchAlarms(String n) async => [];
  @override Future<List<Map<String, dynamic>>> fetchEvents(String n) async => [];
  @override Future<String> resolveLabel(String t, String i) async => '';
  @override Future<List<ActionDescriptor>> getActions(String typeName) async => [
    ActionDescriptor(name: 'test_action', label: 'Test', iconName: 'test'),
  ];
  @override Future<Map<String, dynamic>> invokeAction(String t, String i, String a, Map<String, dynamic> p) async => {
    'success': true, 'message': 'done',
  };
}

void main() {
  group('DataSource actions', () {
    test('getActions returns list', () async {
      final ds = _TestDataSource();
      final actions = await ds.getActions('any');
      expect(actions, isA<List<ActionDescriptor>>());
      expect(actions.length, equals(1));
    });

    test('invokeAction returns result map', () async {
      final ds = _TestDataSource();
      final result = await ds.invokeAction('t', 'i', 'a', {});
      expect(result['success'], isTrue);
      expect(result['message'], equals('done'));
    });

    test('fallback returns empty actions', () async {
      final ds = FallbackDataSource();
      final actions = await ds.getActions('any');
      expect(actions, isEmpty);
    });
  });
}
