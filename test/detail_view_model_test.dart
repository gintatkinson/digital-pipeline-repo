import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/sqlite_repository.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';
import 'package:pipeline_app/features/detail/detail_view_model.dart';

bool _sqfliteInitDone = false;

Future<Repository> _openRepo() async {
  if (!_sqfliteInitDone) {
    sqfliteFfiInit();
    _sqfliteInitDone = true;
  }
  final db = await databaseFactoryFfi.openDatabase(
    'file:test_${Random().nextInt(999999)}?mode=memory&cache=shared',
    options: OpenDatabaseOptions(version: 1, onCreate: (db, v) async {
      await db.execute('CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)');
      await db.execute('CREATE TABLE type_attribute (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name TEXT, attr_key TEXT, label TEXT, attr_type TEXT, section_label TEXT, section_order INTEGER DEFAULT 0, is_required INTEGER DEFAULT 0, min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT, enum_display_names TEXT, default_value TEXT, input_formatters TEXT, UNIQUE(type_name, attr_key))');
      await db.execute('CREATE TABLE type_relation (id INTEGER PRIMARY KEY AUTOINCREMENT, parent_type_name TEXT, relation_name TEXT, child_type_name TEXT, child_label TEXT, UNIQUE(parent_type_name, child_type_name))');
      await db.execute('CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)');
      await db.execute('CREATE TABLE child_entry (id TEXT PRIMARY KEY, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)');
    }),
  );
  return SqliteRepository(SqliteDataSource(db));
}

void main() {
  test('loadNode passes typeName not nodeId — returns fields', () async {
    final r = await _openRepo();
    final db = (r as SqliteRepository).db;
    await db.insert('type_definition', {'type_name': 'Type0', 'display_name': 'Type 0', 'icon_name': 'data_object'});
    await db.insert('type_attribute', {'type_name': 'Type0', 'attr_key': 'attr_01', 'label': 'I_01', 'attr_type': 'int_', 'section_label': 'G_01', 'section_order': 0, 'is_required': 1});
    await db.insert('instance', {'node_id': 'Type0-000', 'data_json': jsonEncode({'attr_01': 42})});

    final vm = DetailViewModel(r);
    await vm.loadNode('Type0', 'Type0-000');
    expect(vm.fields.length, 1);
    expect(vm.properties['attr_01'], 42);
  });

  test('wrong typeName returns empty fields', () async {
    final r = await _openRepo();
    final db = (r as SqliteRepository).db;
    await db.insert('type_definition', {'type_name': 'Type0', 'display_name': 'Type 0', 'icon_name': 'data_object'});
    final vm = DetailViewModel(r);
    await vm.loadNode('Type1', 'Type0-000');
    expect(vm.fields, isEmpty);
  });

  test('loadNode cancels stale in-flight calls via generation counter', () async {
    final repo = _GateRepo();
    repo.addType('TypeA', TypeDescriptor(typeName: 'TypeA', displayName: 'A', iconName: 'data_object'));
    repo.addType('TypeB', TypeDescriptor(typeName: 'TypeB', displayName: 'B', iconName: 'data_object'));
    repo.addProps('TypeA-000', {'value': 0});
    repo.addProps('TypeB-111', {'value': 1});

    final vm = DetailViewModel(repo);

    // Launch both loads concurrently — both suspend at typeFor gate.
    vm.loadNode('TypeA', 'TypeA-000');
    vm.loadNode('TypeB', 'TypeB-111');

    // Resolve TypeB's pipeline first (latest tap wins).
    repo.openType('TypeB');
    await Future.microtask(() {});
    repo.openFetch('TypeB-111');
    await Future.microtask(() {});

    // Now resolve TypeA's pipeline (older tap, should be cancelled).
    repo.openType('TypeA');
    await Future.microtask(() {});
    repo.openFetch('TypeA-000');
    await Future.microtask(() {});

    // Generation counter should have cancelled TypeA's stale call.
    expect(vm.properties['value'], 1,
        reason: 'Final state must match last selected node (TypeB)');
  });

  test('isLoading flag toggles during load', () async {
    final repo = _GateRepo();
    repo.addType('Type0', TypeDescriptor(typeName: 'Type0', displayName: 'T0', iconName: 'data_object'));
    repo.addProps('Type0-000', {'value': 0});

    final vm = DetailViewModel(repo);
    expect(vm.isLoading, false);

    vm.loadNode('Type0', 'Type0-000');
    expect(vm.isLoading, true);

    repo.openType('Type0');
    await Future.microtask(() {}); // flush: typeFor resolves, fetchProperties gate created
    repo.openFetch('Type0-000');
    await Future.microtask(() {}); // flush: fetchProperties resolves, loadNode completes

    expect(vm.isLoading, false);
    expect(vm.properties['value'], 0);
  });

  test('saveProperties persists and notifies', () async {
    final r = await _openRepo();
    final db = (r as SqliteRepository).db;
    await db.insert('type_definition', {'type_name': 'Type0', 'display_name': 'Type 0', 'icon_name': 'data_object'});
    await db.insert('instance', {'node_id': 'Type0-000', 'data_json': jsonEncode({'x': 1})});

    final vm = DetailViewModel(r);
    await vm.loadNode('Type0', 'Type0-000');
    var notified = false;
    vm.addListener(() => notified = true);
    await vm.saveProperties({'x': 99, 'y': 42});
    expect(vm.properties['x'], 99);
    expect(notified, true);

    final props = await r.fetchProperties('Type0-000');
    expect(props!['x'], 99);
  });
}

class _GateRepo implements Repository {
  final _types = <String, TypeDescriptor>{};
  final _props = <String, Map<String, dynamic>>{};
  final _typeGates = <String, Completer<void>>{};
  final _fetchGates = <String, Completer<void>>{};

  void addType(String name, TypeDescriptor td) {
    _types[name] = td;
  }

  void addProps(String nodeId, Map<String, dynamic> data) {
    _props[nodeId] = data;
  }

  void openType(String typeName) {
    _typeGates[typeName]?.complete();
  }

  void openFetch(String nodeId) {
    _fetchGates[nodeId]?.complete();
  }

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final gate = Completer<void>();
    _typeGates[typeName] = gate;
    await gate.future;
    return _types[typeName];
  }

  @override
  Future<Map<String, dynamic>?> fetchProperties(String nodeId) async {
    final gate = Completer<void>();
    _fetchGates[nodeId] = gate;
    await gate.future;
    return _props[nodeId];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChildren(
      String nodeId, String relationName) async {
    return [];
  }

  @override
  Future<List<TypeDescriptor>> discoverTypes() async =>
      _types.values.toList();

  @override
  Future<List<InstanceDescriptor>> discoverInstances() async => [];

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}

  @override
  void close() {}
}
