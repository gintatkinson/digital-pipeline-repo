import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/data_source.dart';

Future<Database> _openDb() async {
  sqfliteFfiInit();
  return databaseFactoryFfi.openDatabase(
    'file:test_${Random().nextInt(999999)}?mode=memory&cache=shared',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, v) async {
        await db.execute('CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)');
        await db.execute('CREATE TABLE type_attribute (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name TEXT, attr_key TEXT, label TEXT, attr_type TEXT, section_label TEXT, section_order INTEGER DEFAULT 0, is_required INTEGER DEFAULT 0, min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT, enum_display_names TEXT, default_value TEXT, input_formatters TEXT, UNIQUE(type_name, attr_key))');
        await db.execute('CREATE TABLE type_relation (id INTEGER PRIMARY KEY AUTOINCREMENT, parent_type_name TEXT, relation_name TEXT, child_type_name TEXT, child_label TEXT, UNIQUE(parent_type_name, child_type_name))');
        await db.execute('CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)');
        await db.execute('CREATE TABLE child_entry (id TEXT PRIMARY KEY, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)');
      },
    ),
  );
}

void main() {
  test('DataSource can be implemented and accessed via SQLite', () async {
    final db = await _openDb();
    final ds = SqliteDataSource(db);
    expect(ds.name, 'sqlite');
    expect(ds, isA<DataSource>());
    await db.close();
  });
}
