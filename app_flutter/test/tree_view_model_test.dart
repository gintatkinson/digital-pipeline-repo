import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/sqlite_repository.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';

Future<Repository> _openRepo() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    'file:test_${Random().nextInt(999999)}?mode=memory&cache=shared',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, v) async {
        await db.execute('CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)');
        await db.execute('CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)');
      },
    ),
  );
  return SqliteRepository(SqliteDataSource(db));
}

void main() {
  test('load populates nodes from repository', () async {
    final repo = await _openRepo();
    final db = (repo as SqliteRepository).db;
    await db.insert('type_definition', {'type_name': 'Type0', 'display_name': 'Type 0', 'icon_name': 'data_object'});
    await db.insert('instance', {'node_id': 'Type0-000', 'data_json': '{}'});
    await db.insert('instance', {'node_id': 'Type0-001', 'data_json': '{}'});

    final vm = TreeViewModel(repo);
    await vm.load();
    expect(vm.nodes.length, 2);
    expect(vm.nodes[0].nodeId, 'Type0-000');
  });

  test('selectNode sets selection and notifies', () async {
    final repo = await _openRepo();
    final db = (repo as SqliteRepository).db;
    await db.insert('type_definition', {'type_name': 'Type0', 'display_name': 'Type 0', 'icon_name': 'data_object'});
    await db.insert('instance', {'node_id': 'Type0-000', 'data_json': '{}'});

    final vm = TreeViewModel(repo);
    await vm.load();
    var notified = false;
    vm.addListener(() => notified = true);
    vm.selectNode('Type0-000');
    expect(vm.selectedNodeId, 'Type0-000');
    expect(notified, true);
  });
}
