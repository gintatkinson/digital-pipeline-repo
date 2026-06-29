import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Map from section-group to display title for the property grid.
const Map<String, String> sectionLabelMap = {
  'Location': 'Geodetic Coordinate Frame',
  'Alternate': 'Alternate Structural Grid Frame',
};

class DatabaseInitializer {
  static const _entriesPerNode = 15;

  static const _nodeIds = [
    'Ingestion',
    'Monitoring', 'Metrics', 'Location', 'Chassis', 'Uptime',
    'Spec', 'Epics', 'Traceability', 'Requirements', 'Releases',
    'Security', 'Access', 'Firewall', 'Certificates', 'Audit',
    'Infrastructure', 'Servers', 'Storage', 'Network',
  ];

  static const _types = [
    'Worker', 'Collector', 'Sensor', 'Power', 'Planning',
    'Compliance', 'Gateway', 'Router', 'Switch', 'Firewall',
    'LoadBalancer', 'Database', 'Cache', 'Queue', 'Monitor',
  ];

  static const _severities = [
    'Critical', 'Warning', 'Info', 'Major', 'Minor',
  ];

  static const _sources = [
    'System', 'Metrics', 'Geo', 'Chassis', 'Agile',
    'Compliance', 'Security', 'Network', 'Storage', 'Database',
    'Orchestrator', 'Monitor', 'Scheduler', 'Auditor', 'Ingress',
  ];

  static const _adminStatuses = ['UP', 'DOWN'];
  static const _locationTypes = ['site', 'room', 'building'];

  /// Seed data for type_definitions: (type_name, display_name, icon_name).
  static const _seedTypeDefs = [
    ('Ingestion', 'Ingestion', 'insert_drive_file'),
    ('Monitoring', 'Monitoring', 'insert_drive_file'),
    ('Metrics', 'Metrics', 'insert_drive_file'),
    ('Location', 'Location', 'insert_drive_file'),
    ('Chassis', 'Chassis', 'insert_drive_file'),
    ('Uptime', 'Uptime', 'insert_drive_file'),
    ('Spec', 'Spec', 'insert_drive_file'),
    ('Epics', 'Epics', 'insert_drive_file'),
    ('Traceability', 'Traceability', 'insert_drive_file'),
    ('Requirements', 'Requirements', 'insert_drive_file'),
    ('Releases', 'Releases', 'insert_drive_file'),
    ('Security', 'Security', 'insert_drive_file'),
    ('Access', 'Access', 'insert_drive_file'),
    ('Firewall', 'Firewall', 'insert_drive_file'),
    ('Certificates', 'Certificates', 'insert_drive_file'),
    ('Audit', 'Audit', 'insert_drive_file'),
    ('Infrastructure', 'Infrastructure', 'insert_drive_file'),
    ('Servers', 'Servers', 'insert_drive_file'),
    ('Storage', 'Storage', 'insert_drive_file'),
    ('Network', 'Network', 'insert_drive_file'),
    ('Alternate', 'Alternate', 'insert_drive_file'),
    ('interface', 'Interface', 'insert_drive_file'),
    ('state', 'State', 'insert_drive_file'),
  ];

  /// Seed data for type_relations: (parent_type, child_type, child_label).
  static const _seedRelations = [
    ('Monitoring', 'Metrics', 'Metrics'),
    ('Monitoring', 'Location', 'Location'),
    ('Monitoring', 'Chassis', 'Chassis'),
    ('Monitoring', 'Uptime', 'Uptime'),
    ('Spec', 'Epics', 'Epics'),
    ('Spec', 'Traceability', 'Traceability'),
    ('Spec', 'Requirements', 'Requirements'),
    ('Spec', 'Releases', 'Releases'),
    ('Security', 'Access', 'Access'),
    ('Security', 'Firewall', 'Firewall'),
    ('Security', 'Certificates', 'Certificates'),
    ('Security', 'Audit', 'Audit'),
    ('Infrastructure', 'Servers', 'Servers'),
    ('Infrastructure', 'Storage', 'Storage'),
    ('Infrastructure', 'Network', 'Network'),
  ];

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

    if (seed) {
      final typeCountResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM type_definitions',
      );
      final typeCount = typeCountResult.first['count'] as int? ?? 0;
      if (typeCount == 0) {
        await _seedTypeMetadata(db);
      }
    }

    return db;
  }

  static String _makeDataJson(String nodeId, int index) {
    final data = {
      'interfaces/interface/name': '${nodeId.toLowerCase()}-eth0',
      'interfaces/interface/state/mtu': 1500 + index,
      'interfaces/interface/state/admin-status':
          _adminStatuses[index % _adminStatuses.length],
      'latitude': 40.0 + index + 0.5,
      'longitude': -74.0 - index * 0.1,
      'altitude': index * 5,
      'roomName': 'Room ${String.fromCharCode(65 + index % 26)}-${index + 1}',
      'gridRow': index + 1,
      'gridColumn': (index % 10) + 1,
      'maxVoltage': 120.0 + index * 10.0,
      'maxAllocatedPower': 1000.0 + index * 250.0,
      'countryCode': ['US', 'UK', 'DE', 'JP', 'SG'][index % 5],
      'locationType': _locationTypes[index % _locationTypes.length],
    };
    return jsonEncode(data);
  }

  static Future<void> _seed(Database db) async {
    final batch = db.batch();

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

  /// Seed attribute definitions from logical-layout.json matching
  /// the hardcoded defaults, display names, and section labels.
  static const _seedAttrs = [
    {
      'key': 'interfaces/interface/name',
      'label': 'The name of the interface',
      'type': 'string',
      'sectionGroup': 'interface',
      'isRequired': false,
    },
    {
      'key': 'interfaces/interface/state/mtu',
      'label': 'The Maximum Transmission Unit',
      'type': 'int',
      'sectionGroup': 'state',
      'isRequired': true,
      'minValue': 68,
      'maxValue': 9216,
    },
    {
      'key': 'interfaces/interface/state/admin-status',
      'label': 'The administrative status of the interface',
      'type': 'enum',
      'sectionGroup': 'state',
      'isRequired': false,
      'options': ['UP', 'DOWN'],
    },
    {
      'key': 'latitude',
      'label': 'Latitude',
      'type': 'double',
      'sectionGroup': 'Location',
      'isRequired': false,
      'defaultValue': 37.7749,
    },
    {
      'key': 'longitude',
      'label': 'Longitude',
      'type': 'double',
      'sectionGroup': 'Location',
      'isRequired': false,
      'defaultValue': -122.4194,
    },
    {
      'key': 'altitude',
      'label': 'Elevation / Altitude (m)',
      'type': 'int',
      'sectionGroup': 'Location',
      'isRequired': false,
      'defaultValue': 10,
    },
    {
      'key': 'roomName',
      'label': 'Room Identifier',
      'type': 'string',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 'Main-Data-Room',
    },
    {
      'key': 'gridRow',
      'label': 'Grid Row',
      'type': 'int',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 12,
    },
    {
      'key': 'gridColumn',
      'label': 'Grid Column',
      'type': 'int',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 4,
    },
    {
      'key': 'maxVoltage',
      'label': 'Max Voltage (V)',
      'type': 'double',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 240.0,
    },
    {
      'key': 'maxAllocatedPower',
      'label': 'Max Allocated Power (W)',
      'type': 'double',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 15000.0,
    },
    {
      'key': 'countryCode',
      'label': 'Country Code (ISO-2)',
      'type': 'string',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'defaultValue': 'US',
      'inputFormatters': ['uppercase', 'maxLength:2'],
    },
    {
      'key': 'locationType',
      'label': 'Location Hierarchy Type',
      'type': 'enum',
      'sectionGroup': 'Alternate',
      'isRequired': false,
      'options': ['site', 'room', 'building', 'invalid-test-option'],
      'displayNames': ['Site', 'Room', 'Building', 'Invalid (Test Only)'],
      'defaultValue': 'room',
    },
  ];

  /// Seed the three type-metadata tables if they are empty.
  static Future<void> _seedTypeMetadata(Database db) async {
    final batch = db.batch();

    // type_definitions
    for (final td in _seedTypeDefs) {
      batch.insert('type_definitions', {
        'type_name': td.$1,
        'display_name': td.$2,
        'icon_name': td.$3,
      });
    }

    // type_relations
    for (final rel in _seedRelations) {
      batch.insert('type_relations', {
        'parent_type_name': rel.$1,
        'relation_name': 'contains',
        'child_type_name': rel.$2,
        'child_label': rel.$3,
      });
    }

    // type_attributes  – group by sectionGroup to compute section_order
    final Map<String, int> sectionCounters = {};
    for (final attr in _seedAttrs) {
      final sg = attr['sectionGroup'] as String;
      final order = sectionCounters.update(sg, (v) => v + 1, ifAbsent: () => 0);

      final List<String>? options = (attr['options'] as List<dynamic>?)
          ?.cast<String>();
      final List<String>? displayNames = (attr['displayNames'] as List<dynamic>?)
          ?.cast<String>();

      batch.insert('type_attributes', {
        'type_name': sg,
        'attr_key': attr['key'] as String,
        'label': attr['label'] as String,
        'attr_type': attr['type'] as String,
        'section_label': sectionLabelMap[sg],
        'section_order': order,
        'is_required': (attr['isRequired'] as bool) ? 1 : 0,
        'min_value': attr['minValue'] as num?,
        'max_value': attr['maxValue'] as num?,
        'enum_options':
            options != null ? jsonEncode(options) : null,
        'enum_display_names':
            displayNames != null ? jsonEncode(displayNames) : null,
        'default_value': attr['defaultValue']?.toString(),
        'input_formatters': attr['inputFormatters'] != null
            ? jsonEncode(attr['inputFormatters'])
            : null,
      });
    }

    await batch.commit(noResult: true);
  }
}
