import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final dbPath = 'assets/properties_db.db';
  final file = File(dbPath);
  if (await file.exists()) {
    await file.delete();
  }
  await DatabaseInitializer.create(dbPath: dbPath, seed: true);
  print('Generic database properties_db.db regenerated successfully.');
}

/// Creates and optionally seeds a local SQLite database for development
/// and testing.
///
/// Generates the full schema (`properties`, `instances`, `type_definitions`,
/// `type_attributes`, `type_relations`) and populates sample data when [seed] is true.
/// Used at app startup when no pre-built database asset exists, or when running in CI/testing environments.
///
/// Call [create] once before any repository operation. The returned
/// [Database] is shared across [SqliteDataSource]. Do not call [create] multiple times for the
/// same path — it reopens the same file and re-runs `CREATE TABLE IF NOT
/// EXISTS`, which is safe but wasteful.
class DatabaseInitializer {
  /// Opens (or creates) the database and ensures all tables exist.
  ///
  /// If [dbPath] is null, the database is placed in the app support
  /// directory as `properties_db.db`. When [seed] is true and the
  /// `properties` table is empty, sample data is inserted. Idempotent for the tables (uses `CREATE TABLE IF NOT
  /// EXISTS`) but NOT for seeding (checks row count first).
  ///
  /// Throws on I/O errors (path resolution, file creation) or SQL
  /// execution failures.
  static Future<Database> create({String? dbPath, bool seed = true}) async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = dbPath != null
        ? (dbPath == inMemoryDatabasePath ? dbPath : p.absolute(dbPath))
        : p.join(
            (await getApplicationSupportDirectory()).path,
            'properties_db.db',
          );

    final db = await databaseFactory.openDatabase(path);
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS properties (
        node_id TEXT PRIMARY KEY,
        data_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS instances (
        id TEXT PRIMARY KEY,
        parent_node_id TEXT NOT NULL,
        type_name TEXT NOT NULL,
        data_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS type_definitions (
        type_name TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        icon_name TEXT NOT NULL DEFAULT 'insert_drive_file'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS type_attributes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
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
      CREATE TABLE IF NOT EXISTS type_relations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
        relation_name TEXT NOT NULL,
        child_type_name TEXT NOT NULL REFERENCES type_definitions(type_name),
        child_label TEXT NOT NULL,
        UNIQUE(parent_type_name, child_type_name)
      )
    ''');

    if (seed) {
      final countResult =
          await db.rawQuery('SELECT COUNT(*) as count FROM type_definitions');
      final count = countResult.first['count'] as int? ?? 0;
      if (count == 0) {
        await _seed(db);
      }
    }

    return db;
  }

  /// Inserts sample data.
  static Future<void> _seed(Database db) async {
    final batch = db.batch();

    // 3 root master type definitions
    final masters = ['Master_A', 'Master_B', 'Master_C'];
    for (final m in masters) {
      batch.insert('type_definitions', {
        'type_name': m,
        'display_name': m.replaceAll('_', ' '),
        'icon_name': 'insert_drive_file',
      });
    }

    // 3 detail type definitions
    final details = ['Detail_A', 'Detail_B', 'Detail_C'];
    for (final d in details) {
      batch.insert('type_definitions', {
        'type_name': d,
        'display_name': d.replaceAll('_', ' '),
        'icon_name': 'widgets',
      });
    }

    // Child type relations connecting each Master Type to all 3 Detail Types
    for (final m in masters) {
      for (final d in details) {
        batch.insert('type_relations', {
          'parent_type_name': m,
          'relation_name': 'contains',
          'child_type_name': d,
          'child_label': d.replaceAll('_', ' '),
        });
      }
    }

    // Seed 3 fields in type_attributes for each of these 6 types: field_1 (Text), field_2 (Text), field_3 (Text)
    final allTypes = [...masters, ...details];
    for (final t in allTypes) {
      for (int i = 1; i <= 3; i++) {
        batch.insert('type_attributes', {
          'type_name': t,
          'attr_key': 'field_$i',
          'label': 'Field $i',
          'attr_type': 'string',
          'section_label': 'General',
          'section_order': 0,
          'is_required': 0,
        });
      }
    }

    // Seed properties for each of the 3 Master Nodes
    for (final m in masters) {
      batch.insert('properties', {
        'node_id': m,
        'data_json': jsonEncode({
          'field_1': 'val_${m}_field_1',
          'field_2': 'val_${m}_field_2',
          'field_3': 'val_${m}_field_3',
        }),
      });
    }

    // Seed 15 instances for each Detail Type belonging to each parent Master Node
    for (final m in masters) {
      for (final d in details) {
        for (int k = 1; k <= 15; k++) {
          final instId = 'inst_${m}_${d}_$k';
          batch.insert('instances', {
            'id': instId,
            'parent_node_id': m,
            'type_name': d,
            'data_json': jsonEncode({
              'field_1': 'val_inst_${m}_${d}_${k}_field_1',
              'field_2': 'val_inst_${m}_${d}_${k}_field_2',
              'field_3': 'val_inst_${m}_${d}_${k}_field_3',
            }),
          });
        }
      }
    }

    await batch.commit(noResult: true);
  }
}
