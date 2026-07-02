import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/sqlite_repository.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/features/detail/topology_view_model.dart';

Future<Repository> _openRepo() async {
  sqfliteFfiInit();
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
  test('default depth hops is 1, max is 3, playing is false', () async {
    final r = await _openRepo();
    final vm = TopologyViewModel(r);
    expect(vm.depthHops, 1);
    expect(vm.maxDepthHops, 3);
    expect(vm.isPlaying, false);
    expect(vm.nodes, isEmpty);
    expect(vm.links, isEmpty);
  });

  test('selectNode sets selection and notifies', () async {
    final r = await _openRepo();
    final vm = TopologyViewModel(r);
    var notified = false;
    vm.addListener(() => notified = true);
    vm.selectNode('Type0-000');
    expect(vm.selectedNodeId, 'Type0-000');
    expect(notified, true);
  });

  test('setDepthHops clamps', () async {
    final r = await _openRepo();
    final vm = TopologyViewModel(r);
    vm.setDepthHops(5);
    expect(vm.depthHops, 3);
  });
}
