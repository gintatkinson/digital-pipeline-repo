import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';

Future<Database> _setupDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    'file:test_${Random().nextInt(999999)}?mode=memory&cache=shared',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE type_definition (
            type_name TEXT PRIMARY KEY,
            display_name TEXT NOT NULL,
            icon_name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE type_attribute (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type_name TEXT NOT NULL,
            attr_key TEXT NOT NULL,
            label TEXT NOT NULL,
            attr_type TEXT NOT NULL,
            section_label TEXT,
            section_order INTEGER NOT NULL DEFAULT 0,
            is_required INTEGER NOT NULL DEFAULT 0,
            min_value REAL,
            max_value REAL,
            pattern TEXT,
            enum_options TEXT,
            enum_display_names TEXT,
            default_value TEXT,
            input_formatters TEXT,
            UNIQUE(type_name, attr_key)
          )
        ''');
        await db.execute('''
          CREATE TABLE type_relation (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            parent_type_name TEXT NOT NULL,
            relation_name TEXT NOT NULL,
            child_type_name TEXT NOT NULL,
            child_label TEXT NOT NULL,
            UNIQUE(parent_type_name, child_type_name)
          )
        ''');
        await db.execute('''
          CREATE TABLE instance (
            node_id TEXT PRIMARY KEY,
            data_json TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE child_entry (
            id TEXT PRIMARY KEY,
            parent_node_id TEXT NOT NULL,
            relation_name TEXT NOT NULL,
            payload_json TEXT
          )
        ''');
      },
    ),
  );
  return db;
}

Future<void> _seedMinimal(Database db) async {
  await db.insert('type_definition', {
    'type_name': 'Type0',
    'display_name': 'Type 0',
    'icon_name': 'data_object',
  });
  await db.insert('type_attribute', {
    'type_name': 'Type0',
    'attr_key': 'attr_01',
    'label': 'I_01',
    'attr_type': 'int_',
    'section_label': 'G_01',
    'section_order': 0,
    'is_required': 1,
  });
  await db.insert('type_attribute', {
    'type_name': 'Type0',
    'attr_key': 'attr_02',
    'label': 'S_02',
    'attr_type': 'string',
    'section_label': 'G_01',
    'section_order': 0,
    'is_required': 0,
  });
  await db.insert('instance', {
    'node_id': 'Type0-000',
    'data_json': jsonEncode({'attr_01': 42, 'attr_02': 'hello'}),
  });
}

void main() {
  late Database db;
  late SqliteDataSource ds;

  setUp(() async {
    db = await _setupDb();
    ds = SqliteDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('name returns sqlite', () {
    expect(ds.name, 'sqlite');
  });

  test('db getter exposes database', () {
    expect(ds.db, same(db));
  });

  group('discoverTypes', () {
    test('returns empty list for empty database', () async {
      final types = await ds.discoverTypes();
      expect(types, isEmpty);
    });

    test('returns type with fields after seed', () async {
      await _seedMinimal(db);
      final types = await ds.discoverTypes();
      expect(types.length, 1);
      expect(types.first.typeName, 'Type0');
      expect(types.first.fields.length, 2);
    });
  });

  group('typeFor', () {
    test('returns null for unknown type', () async {
      final result = await ds.typeFor('Nonexistent');
      expect(result, isNull);
    });

    test('returns type descriptor for known type', () async {
      await _seedMinimal(db);
      final result = await ds.typeFor('Type0');
      expect(result, isNotNull);
      expect(result!.typeName, 'Type0');
      expect(result.fields.length, 2);
    });
  });

  group('discoverInstances', () {
    test('returns empty for empty database', () async {
      final instances = await ds.discoverInstances();
      expect(instances, isEmpty);
    });

    test('returns instances with typeName parsed from nodeId', () async {
      await _seedMinimal(db);
      final instances = await ds.discoverInstances();
      expect(instances.length, 1);
      expect(instances.first.nodeId, 'Type0-000');
      expect(instances.first.typeName, 'Type0');
    });
  });

  group('fetchProperties', () {
    test('returns null for absent node', () async {
      final props = await ds.fetchProperties('nonexistent');
      expect(props, isNull);
    });

    test('returns property map for existing node', () async {
      await _seedMinimal(db);
      final props = await ds.fetchProperties('Type0-000');
      expect(props, isNotNull);
      expect(props!['attr_01'], 42);
      expect(props['attr_02'], 'hello');
    });
  });

  group('saveProperties', () {
    test('inserts new and overwrites existing', () async {
      await ds.saveProperties('Type1-000', {'x': 1});
      final saved = await ds.fetchProperties('Type1-000');
      expect(saved!['x'], 1);

      await ds.saveProperties('Type1-000', {'x': 99});
      final updated = await ds.fetchProperties('Type1-000');
      expect(updated!['x'], 99);
    });
  });

  group('fetchChildren', () {
    test('returns empty for no children', () async {
      final children = await ds.fetchChildren('Type0-000', 'any');
      expect(children, isEmpty);
    });

    test('returns children with payload merged', () async {
      await db.insert('child_entry', {
        'id': 'ce_Type0-000_r_01',
        'parent_node_id': 'Type0-000',
        'relation_name': 'r1',
        'payload_json': jsonEncode({'col_0': 'val', 'col_1': 10}),
      });
      final children = await ds.fetchChildren('Type0-000', 'r1');
      expect(children.length, 1);
      expect(children.first['id'], 'ce_Type0-000_r_01');
      expect(children.first['col_0'], 'val');
      expect(children.first['col_1'], 10);
    });
  });
}
