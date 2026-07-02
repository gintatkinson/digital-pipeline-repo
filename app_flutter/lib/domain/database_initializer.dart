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

  /// Builds a varied JSON property payload for a given node at [index].
  ///
  /// Fields cycle through predefined values (admin statuses, country codes,
  /// place types) using [index] so that different nodes get different data.
  /// The generated JSON is deterministic: same [nodeId] + [index] always
  /// produces the same result.
  static String _makeDataJson(String nodeId, int index) {
    final data = {
      'custom_attribute_1': '${nodeId.toLowerCase()}-prop-1',
      'custom_attribute_2': 1500 + index,
      'custom_attribute_3': index % 2 == 0 ? 'Active' : 'Inactive',
      'custom_attribute_4': 40.0 + index + 0.5,
      'custom_attribute_5': -74.0 - index * 0.1,
      'custom_attribute_6': index * 5,
      'custom_attribute_7': 'Prop ${index + 1}',
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

    // Seed type definitions
    batch.insert('type_definitions', {
      'type_name': 'Item',
      'display_name': 'Item',
      'icon_name': 'insert_drive_file',
    });
    batch.insert('type_definitions', {
      'type_name': 'Component',
      'display_name': 'Component',
      'icon_name': 'widgets',
    });
    batch.insert('type_definitions', {
      'type_name': 'RelationA',
      'display_name': 'Relation A',
      'icon_name': 'warning',
    });
    batch.insert('type_definitions', {
      'type_name': 'RelationB',
      'display_name': 'Relation B',
      'icon_name': 'event',
    });

    // Seed type attributes for Item
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'name',
      'label': 'Name',
      'attr_type': 'string',
      'section_label': 'General',
      'section_order': 0,
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'description',
      'label': 'Description',
      'attr_type': 'string',
      'section_label': 'General',
      'section_order': 0,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_1',
      'label': 'Custom Attribute 1',
      'attr_type': 'string',
      'section_label': 'General',
      'section_order': 0,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_2',
      'label': 'Custom Attribute 2',
      'attr_type': 'integer',
      'section_label': 'General',
      'section_order': 0,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_3',
      'label': 'Custom Attribute 3',
      'attr_type': 'string',
      'section_label': 'General',
      'section_order': 0,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_4',
      'label': 'Custom Attribute 4',
      'attr_type': 'real',
      'section_label': 'Section A',
      'section_order': 1,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_5',
      'label': 'Custom Attribute 5',
      'attr_type': 'real',
      'section_label': 'Section A',
      'section_order': 1,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_6',
      'label': 'Custom Attribute 6',
      'attr_type': 'integer',
      'section_label': 'Section B',
      'section_order': 2,
      'is_required': 0,
    });
    batch.insert('type_attributes', {
      'type_name': 'Item',
      'attr_key': 'custom_attribute_7',
      'label': 'Custom Attribute 7',
      'attr_type': 'string',
      'section_label': 'Section B',
      'section_order': 2,
      'is_required': 0,
    });

    // Seed type attributes for Component
    batch.insert('type_attributes', {
      'type_name': 'Component',
      'attr_key': 'id',
      'label': 'ID',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'Component',
      'attr_key': 'name',
      'label': 'Name',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'Component',
      'attr_key': 'status',
      'label': 'Status',
      'attr_type': 'string',
      'enum_options': '["Active","Standby","Error"]',
    });

    // Seed type attributes for RelationA
    batch.insert('type_attributes', {
      'type_name': 'RelationA',
      'attr_key': 'id',
      'label': 'ID',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationA',
      'attr_key': 'target',
      'label': 'Target',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationA',
      'attr_key': 'severity',
      'label': 'Severity',
      'attr_type': 'string',
      'enum_options': '["Critical","Warning","Info","Major","Minor"]',
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationA',
      'attr_key': 'timestamp',
      'label': 'Timestamp',
      'attr_type': 'string',
    });

    // Seed type attributes for RelationB
    batch.insert('type_attributes', {
      'type_name': 'RelationB',
      'attr_key': 'id',
      'label': 'ID',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationB',
      'attr_key': 'source',
      'label': 'Source',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationB',
      'attr_key': 'message',
      'label': 'Message',
      'attr_type': 'string',
      'is_required': 1,
    });
    batch.insert('type_attributes', {
      'type_name': 'RelationB',
      'attr_key': 'timestamp',
      'label': 'Timestamp',
      'attr_type': 'string',
    });

    // Seed type relations
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'contains',
      'child_type_name': 'Component',
      'child_label': 'Components',
    });
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'affects',
      'child_type_name': 'RelationA',
      'child_label': 'Relation A',
    });
    batch.insert('type_relations', {
      'parent_type_name': 'Item',
      'relation_name': 'records',
      'child_type_name': 'RelationB',
      'child_label': 'Relation B',
    });

    for (var i = 0; i < _nodeIds.length; i++) {
      final nodeId = _nodeIds[i];

      batch.insert('properties', {
        'node_id': nodeId,
        'data_json': _makeDataJson(nodeId, i),
      });

      for (var j = 0; j < _entriesPerNode; j++) {
        final elemId = 'elem-$nodeId-${j + 1}';
        batch.insert('instances', {
          'id': elemId,
          'parent_node_id': nodeId,
          'type_name': 'Component',
          'data_json': jsonEncode({
            'id': elemId,
            'name': '${nodeId} Component ${j + 1}',
            'status': j % 3 == 0 ? 'Active' : (j % 3 == 1 ? 'Standby' : 'Error'),
          }),
        });

        final alarmId = 'alarm-$nodeId-${j + 1}';
        batch.insert('instances', {
          'id': alarmId,
          'parent_node_id': nodeId,
          'type_name': 'RelationA',
          'data_json': jsonEncode({
            'id': alarmId,
            'target': '${nodeId} Target ${j + 1}',
            'severity': _severities[(i + j) % _severities.length],
            'timestamp': '2026-06-${(j % 28) + 1}',
          }),
        });

        final eventId = 'event-$nodeId-${j + 1}';
        batch.insert('instances', {
          'id': eventId,
          'parent_node_id': nodeId,
          'type_name': 'RelationB',
          'data_json': jsonEncode({
            'id': eventId,
            'source': _sources[(i + j) % _sources.length],
            'message': '${nodeId} relation ${j + 1}: ${_sources[(i + j) % _sources.length]} update',
            'timestamp': '2026-06-${(j % 28) + 1}',
          }),
        });
      }
    }
    // Also seed properties and instances for metadata types (used in tests and default views)
    for (final nodeId in ['Item', 'Component', 'RelationA', 'RelationB']) {
      batch.insert('properties', {
        'node_id': nodeId,
        'data_json': '{"name":"Sample $nodeId","description":"Description for $nodeId"}',
      });
      batch.insert('instances', {
        'id': 'elem-$nodeId-seed',
        'parent_node_id': nodeId,
        'type_name': 'Component',
        'data_json': jsonEncode({
          'id': 'elem-$nodeId-seed',
          'name': '$nodeId Component',
          'status': 'Active',
        }),
      });
      batch.insert('instances', {
        'id': 'alarm-$nodeId-seed',
        'parent_node_id': nodeId,
        'type_name': 'RelationA',
        'data_json': jsonEncode({
          'id': 'alarm-$nodeId-seed',
          'target': '$nodeId Target',
          'severity': 'Warning',
          'timestamp': '2026-06-01',
        }),
      });
      batch.insert('instances', {
        'id': 'event-$nodeId-seed',
        'parent_node_id': nodeId,
        'type_name': 'RelationB',
        'data_json': jsonEncode({
          'id': 'event-$nodeId-seed',
          'source': 'System',
          'message': '$nodeId Relation B seeded',
          'timestamp': '2026-06-01',
        }),
      });
    }

    await batch.commit(noResult: true);
  }

}
