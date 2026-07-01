import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates and optionally seeds a local SQLite database for development
/// and testing.
///
/// Generates the full schema (`properties`, `elements`, `alarms`, `events`,
/// `type_definitions`, `type_attributes`, `type_relations`) and populates
/// sample data when [seed] is true. Used at app startup when no pre-built
/// database asset exists, or when running in CI/testing environments.
///
/// Call [create] once before any repository operation. The returned
/// [Database] is shared across [SqliteRepositoryAdapter] and
/// [SqliteDataSource]. Do not call [create] multiple times for the
/// same path — it reopens the same file and re-runs `CREATE TABLE IF NOT
/// EXISTS`, which is safe but wasteful.
class DatabaseInitializer {
  /// Number of seed rows per node (elements, alarms, events each get this many).
  static const _entriesPerNode = 15;

  /// Node IDs seeded as root and tree branches for demo data.
  static const _nodeIds = [
    'root',
    'Overview', 'Watch', 'Measure', 'Position', 'Unit', 'Status',
    'Spec', 'Capability', 'Path', 'Objective', 'Phase',
    'Perimeter', 'Entry', 'Bridge', 'Principal', 'Journal',
    'Base', 'Process', 'Store', 'Mesh',
  ];

  /// Object type names assigned to seeded elements.
  static const _types = [
    'Processor', 'Collector', 'Sensor', 'Actuator', 'Controller',
    'Validator', 'Dispatcher', 'Distributor', 'Adapter', 'Filter',
    'Aggregator', 'Store', 'Buffer', 'Channel', 'Observer',
  ];

  /// Alarm severity levels cycled through seeded alarms.
  static const _severities = [
    'Critical', 'Warning', 'Info', 'Major', 'Minor',
  ];

  /// Event source names cycled through seeded events.
  static const _sources = [
    'Core', 'Count', 'Coord', 'Unit', 'Plan',
    'Rule', 'Gate', 'Link', 'Archive', 'Catalog',
    'Coordinator', 'Watch', 'Timer', 'Checker', 'Entry',
  ];

  /// Admin status values assigned alternately to seed data.
  static const _adminStatuses = ['ACTIVE', 'INACTIVE'];

  /// Geographic place types assigned cyclically to seed locations.
  static const _placeTypes = ['zone', 'area', 'cluster'];

  /// Opens (or creates) the database and ensures all tables exist.
  ///
  /// If [dbPath] is null, the database is placed in the app support
  /// directory as `properties_db.db`. When [seed] is true and the
  /// `properties` table is empty, sample data is inserted for every
  /// node defined in [_nodeIds] — each with 15 elements, alarms, and
  /// events. Idempotent for the tables (uses `CREATE TABLE IF NOT
  /// EXISTS`) but NOT for seeding (checks row count first).
  ///
  /// Throws on I/O errors (path resolution, file creation) or SQL
  /// execution failures.
  static Future<Database> create({String? dbPath, bool seed = true}) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = dbPath ??
        p.join(
          (await getApplicationSupportDirectory()).path,
          'properties_db.db',
        );

    final db = await databaseFactory.openDatabase(path);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS properties (
        node_id TEXT PRIMARY KEY,
        data_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS elements (
        id TEXT PRIMARY KEY,
        parent_node_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS alarms (
        id TEXT PRIMARY KEY,
        parent_node_id TEXT NOT NULL,
        target TEXT NOT NULL,
        severity TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        parent_node_id TEXT NOT NULL,
        source TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL
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
          await db.rawQuery('SELECT COUNT(*) as count FROM properties');
      final count = countResult.first['count'] as int? ?? 0;
      if (count == 0) {
        await _seed(db);
      }
    }

    return db;
  }

  /// Builds a varied JSON property payload for a given node at [index].
  ///
  /// Fields cycle through predefined values (admin statuses, country codes,
  /// place types) using [index] so that different nodes get different data.
  /// The generated JSON is deterministic: same [nodeId] + [index] always
  /// produces the same result.
  static String _makeDataJson(String nodeId, int index) {
    final data = {
      'interfaces/interface/name': '${nodeId.toLowerCase()}-eth0',
      'interfaces/interface/state/mtu': 1500 + index,
      'interfaces/interface/state/admin-status':
          _adminStatuses[index % _adminStatuses.length],
      'latitude': 40.0 + index + 0.5,
      'longitude': -74.0 - index * 0.1,
      'altitude': index * 5,
      'placeName': 'Place ${String.fromCharCode(65 + index % 26)}-${index + 1}',
      'gridRow': index + 1,
      'gridColumn': (index % 10) + 1,
      'maxVoltage': 120.0 + index * 10.0,
      'maxAllocatedPower': 1000.0 + index * 250.0,
      'countryCode': ['US', 'UK', 'DE', 'JP', 'SG'][index % 5],
      'placeType': _placeTypes[index % _placeTypes.length],
    };
    return jsonEncode(data);
  }

  /// Inserts sample data for every node in [_nodeIds].
  ///
  /// Each node gets one property row and [_entriesPerNode] elements,
  /// alarms, and events. Uses a batch for performance. Throws on
  /// constraint violations (duplicate keys) — practically never because
  /// this is only called when the `properties` table is empty.
  static Future<void> _seed(Database db) async {
    final batch = db.batch();

    // Seed metadata types matching FallbackDataSource
    batch.insert('type_definitions', {
      'type_name': 'Item',
      'display_name': 'Item',
      'icon_name': 'insert_drive_file',
    });
    batch.insert('type_definitions', {
      'type_name': 'SubElement',
      'display_name': 'Sub Element',
      'icon_name': 'widgets',
    });
    batch.insert('type_definitions', {
      'type_name': 'Alarm',
      'display_name': 'Alarm',
      'icon_name': 'warning',
    });
    batch.insert('type_definitions', {
      'type_name': 'Event',
      'display_name': 'Event',
      'icon_name': 'event',
    });

    // Item fields
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'name',
      'label': 'Name',
      'attr_type': 'string',
      'section_order': 0,
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'description',
      'label': 'Description',
      'attr_type': 'string',
      'section_order': 1,
      'is_required': 0,
    });

    // SubElement fields
    batch.insert('type_attributes', {
      'type_name': 'SubElement',
      'attr_key': 'id',
      'label': 'ID',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'SubElement',
      'attr_key': 'name',
      'label': 'Name',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'SubElement',
      'attr_key': 'type',
      'label': 'Type',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'SubElement',
      'attr_key': 'status',
      'label': 'Status',
      'attr_type': 'string',
    });

    // Alarm fields
    batch.insert('type_attributes', {
      'type_name': 'Alarm',
      'attr_key': 'id',
      'label': 'Alarm ID',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Alarm',
      'attr_key': 'target',
      'label': 'Target',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Alarm',
      'attr_key': 'severity',
      'label': 'Severity',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Alarm',
      'attr_key': 'timestamp',
      'label': 'Timestamp',
      'attr_type': 'string',
    });

    // Event fields
    batch.insert('type_attributes', {
      'type_name': 'Event',
      'attr_key': 'id',
      'label': 'Event ID',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Event',
      'attr_key': 'source',
      'label': 'Source',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Event',
      'attr_key': 'message',
      'label': 'Message',
      'attr_type': 'string',
    });
    batch.insert('type_attributes', {
      'type_name': 'Event',
      'attr_key': 'timestamp',
      'label': 'Timestamp',
      'attr_type': 'string',
    });

    // Relations matching FallbackDataSource
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'contains',
      'child_type_name': 'SubElement',
      'child_label': 'Items',
    });
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'affects',
      'child_type_name': 'Alarm',
      'child_label': 'Alarms',
    });
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'records',
      'child_type_name': 'Event',
      'child_label': 'Events',
    });

    for (var i = 0; i < _nodeIds.length; i++) {
      final nodeId = _nodeIds[i];

      batch.insert('properties', {
        'node_id': nodeId,
        'data_json': _makeDataJson(nodeId, i),
      });

      for (var j = 0; j < _entriesPerNode; j++) {
        final elemId = 'elem-$nodeId-${j + 1}';
        batch.insert('elements', {
          'id': elemId,
          'parent_node_id': nodeId,
          'name': '${nodeId} Element ${j + 1}',
          'type': _types[(i + j) % _types.length],
          'status': j % 3 == 0 ? 'Active' : (j % 3 == 1 ? 'Standby' : 'Error'),
        });

        final alarmId = 'alarm-$nodeId-${j + 1}';
        batch.insert('alarms', {
          'id': alarmId,
          'parent_node_id': nodeId,
          'target': '${nodeId} Target ${j + 1}',
          'severity': _severities[(i + j) % _severities.length],
          'timestamp': '2026-06-${(j % 28) + 1}',
        });

        final eventId = 'event-$nodeId-${j + 1}';
        batch.insert('events', {
          'id': eventId,
          'parent_node_id': nodeId,
          'source': _sources[(i + j) % _sources.length],
          'message': '${nodeId} event ${j + 1}: ${_sources[(i + j) % _sources.length]} notification',
          'timestamp': '2026-06-${(j % 28) + 1}',
        });
      }
    }

    await batch.commit(noResult: true);
  }

}
