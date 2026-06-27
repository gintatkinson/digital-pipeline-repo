import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
}
