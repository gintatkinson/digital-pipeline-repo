import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  final db = await DatabaseInitializer.create(dbPath: dbPath, seed: true);
  await db.close();
  print('Generic database properties_db.db regenerated successfully.');

  final gzFile = File('assets/properties_db.db.gz');
  if (await gzFile.exists()) {
    await gzFile.delete();
  }
  final bytes = await file.readAsBytes();
  final gzipped = gzip.encode(bytes);
  await gzFile.writeAsBytes(gzipped);
  print('Database gzipped to properties_db.db.gz successfully.');
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
  static Future<Database> create({String? dbPath, bool seed = false}) async {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (isDesktop && !isTest) {
      final canAccess = await _probeFfiViability();
      if (!canAccess) {
        throw StateError(
          'Cannot open database on this desktop environment. '
          'The FFI SQLite backend is blocked by the system sandbox. '
          'Grant file-access entitlements or use a non-sandboxed deployment.',
        );
      }
    }
    if (!kIsWeb && (isTest || isDesktop)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String path;
    if (kIsWeb) {
      path = dbPath ?? inMemoryDatabasePath;
    } else {
      path = dbPath != null
          ? (dbPath == inMemoryDatabasePath ? dbPath : p.absolute(dbPath))
          : p.join(
              (await getApplicationSupportDirectory()).path,
              'properties_db.db',
            );
    }

    final db = await databaseFactory.openDatabase(path);
    try {
      await db.execute('PRAGMA journal_mode = WAL;');
      await db.execute('PRAGMA busy_timeout = 5000;');
      await db.execute('PRAGMA foreign_keys = ON;');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS properties (
          node_id TEXT PRIMARY KEY,
          parent_node_id TEXT REFERENCES properties(node_id),
          data_json TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_properties_parent_node_id
        ON properties(parent_node_id);
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
        CREATE INDEX IF NOT EXISTS idx_instances_parent_type
        ON instances(parent_node_id, type_name);
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_instances_type_name
        ON instances(type_name);
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

      await db.execute('''
        UPDATE properties 
        SET parent_node_id = 'L0 (Optical)' 
        WHERE node_id = 'node-SD_CH' AND (parent_node_id IS NULL OR parent_node_id = '');
      ''');

      return db;
    } catch (e) {
      await db.close();
      rethrow;
    }
  }

  static Future<bool> _probeFfiViability() async {
    try {
      sqfliteFfiInit();
      final probe = await databaseFactoryFfi
          .openDatabase(inMemoryDatabasePath)
          .timeout(const Duration(seconds: 2));
      await probe.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Inserts sample data.
  static Future<void> _seed(Database db) async {
    final batch = db.batch();

    final spaceDetails = ['Components', 'Telemetry', 'Logs', 'Links'];
    final nttDetails = ['Components', 'Alarms', 'Links'];
    final landingDetails = ['Components', 'Links'];

    final displayNames = {
      'Components': 'Components',
      'Telemetry': 'Telemetry',
      'Logs': 'Logs',
      'Alarms': 'Alarms',
      'Links': 'Links',
    };

    for (final d in displayNames.keys) {
      batch.insert('type_definitions', {
        'type_name': d,
        'display_name': displayNames[d] ?? d,
        'icon_name': 'widgets',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      for (int i = 1; i <= 50; i++) {
        batch.insert('type_attributes', {
          'type_name': d,
          'attr_key': 'field_$i',
          'label': 'Field $i',
          'attr_type': 'string',
          'section_label': 'General',
          'section_order': 0,
          'is_required': 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    final spaceNodes = <String>[];
    for (int i = 0; i < 100; i++) {
      final id = 'space_$i';
      spaceNodes.add(id);
      final lat = 25.0 + (i / 100.0) * 20.0;
      final lon = 125.0 + (i % 20) * 1.0;
      _addNodeToBatch(batch, id, null, spaceDetails, lat: lat, lon: lon, height: 500000.0);
    }

    final nttFile = File('assets/ntt_exchanges_japan_763.json');
    String nttJsonString;
    if (await nttFile.exists()) {
      nttJsonString = await nttFile.readAsString();
    } else {
      nttJsonString = await rootBundle.loadString('assets/ntt_exchanges_japan_763.json');
    }
    final nttJson = jsonDecode(nttJsonString) as List;

    final nttNodes = <Map<String, dynamic>>[];
    for (int i = 0; i < nttJson.length; i++) {
      final item = nttJson[i];
      final id = 'ntt_exchange_$i';
      nttNodes.add({
        'id': id,
        'lat': (item['latitude'] as num).toDouble(),
        'lon': (item['longitude'] as num).toDouble(),
      });
      _addNodeToBatch(batch, id, null, nttDetails, lat: (item['latitude'] as num).toDouble(), lon: (item['longitude'] as num).toDouble(), height: 0.0);
    }

    final landingFile = File('assets/cable_landing_stations_japan.json');
    String landingJsonString;
    if (await landingFile.exists()) {
      landingJsonString = await landingFile.readAsString();
    } else {
      landingJsonString = await rootBundle.loadString('assets/cable_landing_stations_japan.json');
    }
    final landingJson = jsonDecode(landingJsonString) as List;

    final landingNodes = <Map<String, dynamic>>[];
    for (int i = 0; i < landingJson.length; i++) {
      final item = landingJson[i];
      final id = 'cable_landing_$i';
      landingNodes.add({
        'id': id,
        'lat': (item['latitude'] as num).toDouble(),
        'lon': (item['longitude'] as num).toDouble(),
      });
      _addNodeToBatch(batch, id, null, landingDetails, lat: (item['latitude'] as num).toDouble(), lon: (item['longitude'] as num).toDouble(), height: 0.0);
    }

    final Set<String> addedLinks = {};
    int linkIdCounter = 0;

    void addLink(String from, String to) {
      final key1 = '${from}_$to';
      final key2 = '${to}_$from';
      if (!addedLinks.contains(key1) && !addedLinks.contains(key2)) {
        addedLinks.add(key1);
        addedLinks.add(key2);
        batch.insert('instances', {
          'id': 'link_${linkIdCounter++}',
          'parent_node_id': from,
          'type_name': 'interface',
          'data_json': jsonEncode({'description': 'link to node $to'}),
        });
      }
    }

    double distSq(double lat1, double lon1, double lat2, double lon2) {
      return (lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2);
    }

    for (int i = 0; i < nttNodes.length; i++) {
      final current = nttNodes[i];
      final distances = <Map<String, dynamic>>[];
      for (int j = 0; j < nttNodes.length; j++) {
        if (i == j) continue;
        final target = nttNodes[j];
        distances.add({
          'id': target['id'],
          'dist': distSq(current['lat'], current['lon'], target['lat'], target['lon']),
        });
      }
      distances.sort((a, b) => (a['dist'] as double).compareTo(b['dist'] as double));
      for (int k = 0; k < 2 && k < distances.length; k++) {
        addLink(current['id'], distances[k]['id']);
      }
      
      final space1 = spaceNodes[(i * 2) % 100];
      final space2 = spaceNodes[(i * 2 + 1) % 100];
      addLink(current['id'], space1);
      addLink(current['id'], space2);
    }

    for (int i = 0; i < landingNodes.length; i++) {
      final current = landingNodes[i];
      final distances = <Map<String, dynamic>>[];
      for (int j = 0; j < nttNodes.length; j++) {
        final target = nttNodes[j];
        distances.add({
          'id': target['id'],
          'dist': distSq(current['lat'], current['lon'], target['lat'], target['lon']),
        });
      }
      distances.sort((a, b) => (a['dist'] as double).compareTo(b['dist'] as double));
      for (int k = 0; k < 5 && k < distances.length; k++) {
        addLink(current['id'], distances[k]['id']);
      }
    }

    await batch.commit(noResult: true);
  }

  static void _addNodeToBatch(
    Batch batch,
    String node,
    String? parent,
    List<String> details, {
    required double lat,
    required double lon,
    required double height,
  }) {
    batch.insert('type_definitions', {
      'type_name': node,
      'display_name': node.replaceAll('_', ' '),
      'icon_name': 'insert_drive_file',
    });

    for (final d in details) {
      batch.insert('type_relations', {
        'parent_type_name': node,
        'relation_name': 'contains',
        'child_type_name': d,
        'child_label': d == 'Components' ? 'Components' : d.replaceAll('_', ' ').split(' ').map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1)).join(' '),
      });
    }

    for (int i = 1; i <= 50; i++) {
      batch.insert('type_attributes', {
        'type_name': node,
        'attr_key': 'field_$i',
        'label': 'Field $i',
        'attr_type': 'string',
        'section_label': 'General',
        'section_order': 0,
        'is_required': 0,
      });
    }

    final propertiesMap = {
      for (int j = 1; j <= 50; j++) 'field_$j': 'val_${node}_field_$j',
      'location': {
        'ellipsoid': {
          'latitude': lat,
          'longitude': lon,
          'height': height,
        }
      }
    };
    batch.insert('properties', {
      'node_id': node,
      'parent_node_id': parent,
      'data_json': jsonEncode(propertiesMap),
    });

    for (final d in details) {
      for (int k = 1; k <= 5; k++) {
        final instId = 'inst_${node}_${d}_$k';
        final instanceMap = {
          for (int j = 1; j <= 50; j++) 'field_$j': 'val_inst_${node}_${d}_${k}_field_$j'
        };
        batch.insert('instances', {
          'id': instId,
          'parent_node_id': node,
          'type_name': d,
          'data_json': jsonEncode(instanceMap),
        });
      }
    }
  }
}

