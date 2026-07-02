import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/seed_system_data.dart';

Future<Database> _createDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    'file:test_${Random().nextInt(999999)}?mode=memory&cache=shared',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)',
        );
        await db.execute(
          'CREATE TABLE type_attribute (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name TEXT, attr_key TEXT, label TEXT, attr_type TEXT, section_label TEXT, section_order INTEGER DEFAULT 0, is_required INTEGER DEFAULT 0, min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT, enum_display_names TEXT, default_value TEXT, input_formatters TEXT, UNIQUE(type_name, attr_key))',
        );
        await db.execute(
          'CREATE TABLE type_relation (id INTEGER PRIMARY KEY AUTOINCREMENT, parent_type_name TEXT, relation_name TEXT, child_type_name TEXT, child_label TEXT, UNIQUE(parent_type_name, child_type_name))',
        );
        await db.execute(
          'CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)',
        );
        await db.execute(
          'CREATE TABLE child_entry (id TEXT PRIMARY KEY, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)',
        );
      },
    ),
  );
  return db;
}

Future<int> _count(Database db, String table) async {
  final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
  return result.first['c'] as int;
}

void main() {
  const config = SeedConfig(
    typeCount: 8,
    masterCount: 100,
    attributesPerType: 50,
    sectionsPerType: 5,
    relationCountPerType: 3,
    rowsPerRelation: 90,
  );

  late Database db;

  setUp(() async {
    db = await _createDb();
  });

  tearDown(() async {
    await db.close();
  });

  test('seeds type_definition count', () async {
    await seedSystemData(db, config);
    expect(await _count(db, 'type_definition'), 8);
  });

  test('seeds type_attribute count', () async {
    await seedSystemData(db, config);
    expect(await _count(db, 'type_attribute'), 400);
  });

  test('seeds type_relation count', () async {
    await seedSystemData(db, config);
    expect(await _count(db, 'type_relation'), 24);
  });

  test('seeds instance count', () async {
    await seedSystemData(db, config);
    expect(await _count(db, 'instance'), 100);
  });

  test('seeds child_entry count', () async {
    await seedSystemData(db, config);
    expect(await _count(db, 'child_entry'), 27000);
  });

  test('type names follow formula pattern', () async {
    await seedSystemData(db, config);
    final rows = await db.query('type_definition', orderBy: 'type_name');
    expect(rows.length, 8);
    for (var i = 0; i < 8; i++) {
      expect(rows[i]['type_name'], 'Type$i');
      expect(rows[i]['display_name'], 'Type $i');
    }
  });

  test('attribute keys follow formula attr_NN pattern', () async {
    await seedSystemData(db, config);
    final rows = await db.query('type_attribute', where: 'type_name = ?', whereArgs: ['Type0'], orderBy: 'attr_key');
    expect(rows.length, 50);
    for (var i = 0; i < 50; i++) {
      expect(rows[i]['attr_key'], 'attr_${(i + 1).toString().padLeft(2, '0')}');
    }
  });

  test('node IDs follow formula TypeN-NNN pattern', () async {
    await seedSystemData(db, config);
    final rows = await db.query('instance', where: "node_id LIKE 'Type0-%'", orderBy: 'node_id');
    expect(rows.isNotEmpty, true);
    for (var i = 0; i < rows.length; i++) {
      expect(rows[i]['node_id'], 'Type0-${i.toString().padLeft(3, '0')}');
    }
  });
}
