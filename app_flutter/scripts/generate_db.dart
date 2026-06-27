import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const entriesPerNode = 15;

const nodeIds = [
  'Ingestion',
  'Monitoring', 'Metrics', 'Location', 'Chassis', 'Uptime',
  'Spec', 'Epics', 'Traceability', 'Requirements', 'Releases',
  'Security', 'Access', 'Firewall', 'Certificates', 'Audit',
  'Infrastructure', 'Servers', 'Storage', 'Network',
];

const types = [
  'Worker', 'Collector', 'Sensor', 'Power', 'Planning',
  'Compliance', 'Gateway', 'Router', 'Switch', 'Firewall',
  'LoadBalancer', 'Database', 'Cache', 'Queue', 'Monitor',
];

const severities = [
  'Critical', 'Warning', 'Info', 'Major', 'Minor',
];

const sources = [
  'System', 'Metrics', 'Geo', 'Chassis', 'Agile',
  'Compliance', 'Security', 'Network', 'Storage', 'Database',
  'Orchestrator', 'Monitor', 'Scheduler', 'Auditor', 'Ingress',
];

const adminStatuses = ['UP', 'DOWN'];
const locationTypes = ['site', 'room', 'building'];

String makeDataJson(String nodeId, int index) {
  final data = {
    'interfaces/interface/name': '${nodeId.toLowerCase()}-eth0',
    'interfaces/interface/state/mtu': 1500 + index,
    'interfaces/interface/state/admin-status':
        adminStatuses[index % adminStatuses.length],
    'latitude': 40.0 + index + 0.5,
    'longitude': -74.0 - index * 0.1,
    'altitude': index * 5,
    'roomName': 'Room ${String.fromCharCode(65 + index % 26)}-${index + 1}',
    'gridRow': index + 1,
    'gridColumn': (index % 10) + 1,
    'maxVoltage': 120.0 + index * 10.0,
    'maxAllocatedPower': 1000.0 + index * 250.0,
    'countryCode': ['US', 'UK', 'DE', 'JP', 'SG'][index % 5],
    'locationType': locationTypes[index % locationTypes.length],
  };
  return jsonEncode(data);
}

Future<void> main(List<String> args) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final outputPath = args.isNotEmpty
      ? args[0]
      : p.join(Directory.current.path, 'assets', 'properties_db.db');

  // Ensure parent directory exists
  final dir = Directory(p.dirname(outputPath));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // Delete any existing database file for a clean build
  if (await File(outputPath).exists()) {
    await databaseFactory.deleteDatabase(outputPath);
  }

  print('Creating database at: $outputPath');
  final db = await databaseFactory.openDatabase(outputPath);

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

  final batch = db.batch();

  for (var i = 0; i < nodeIds.length; i++) {
    final nodeId = nodeIds[i];

    batch.insert('properties', {
      'node_id': nodeId,
      'data_json': makeDataJson(nodeId, i),
    });

    for (var j = 0; j < entriesPerNode; j++) {
      batch.insert('elements', {
        'id': 'elem-$nodeId-${j + 1}',
        'parent_node_id': nodeId,
        'name': '${nodeId} Element ${j + 1}',
        'type': types[(i + j) % types.length],
        'status': j % 3 == 0 ? 'Active' : (j % 3 == 1 ? 'Standby' : 'Error'),
      });

      batch.insert('alarms', {
        'id': 'alarm-$nodeId-${j + 1}',
        'parent_node_id': nodeId,
        'target': '${nodeId} Target ${j + 1}',
        'severity': severities[(i + j) % severities.length],
        'timestamp': '2026-06-${(j % 28) + 1}',
      });

      batch.insert('events', {
        'id': 'event-$nodeId-${j + 1}',
        'parent_node_id': nodeId,
        'source': sources[(i + j) % sources.length],
        'message': '${nodeId} event ${j + 1}: ${sources[(i + j) % sources.length]} notification',
        'timestamp': '2026-06-${(j % 28) + 1}',
      });
    }
  }

  await batch.commit(noResult: true);
  await db.close();

  final fullPath = File(outputPath).absolute.path;
  final size = File(outputPath).lengthSync();
  print('Database generated: $fullPath ($size bytes, ${nodeIds.length} nodes x $entriesPerNode entries)');
}
