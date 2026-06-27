import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseInitializer {
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

  static Future<void> _seed(Database db) async {
    final batch = db.batch();

    // properties for each node
    batch.insert('properties', {
      'node_id': 'Ingestion',
      'data_json': '{}',
    });
    batch.insert('properties', {
      'node_id': 'Metrics',
      'data_json': '{}',
    });
    batch.insert('properties', {
      'node_id': 'Location',
      'data_json': '{}',
    });
    batch.insert('properties', {
      'node_id': 'Chassis',
      'data_json': '{}',
    });
    batch.insert('properties', {
      'node_id': 'Epics',
      'data_json': '{}',
    });
    batch.insert('properties', {
      'node_id': 'Traceability',
      'data_json': '{}',
    });

    // elements
    batch.insert('elements', {
      'id': 'elem-ingestion-1',
      'parent_node_id': 'Ingestion',
      'name': 'Ingestion Pipeline',
      'type': 'Worker',
      'status': 'Active',
    });
    batch.insert('elements', {
      'id': 'elem-metrics-1',
      'parent_node_id': 'Metrics',
      'name': 'Network Metrics',
      'type': 'Collector',
      'status': 'Active',
    });
    batch.insert('elements', {
      'id': 'elem-location-1',
      'parent_node_id': 'Location',
      'name': 'GPS Coordinates',
      'type': 'Sensor',
      'status': 'Active',
    });
    batch.insert('elements', {
      'id': 'elem-chassis-1',
      'parent_node_id': 'Chassis',
      'name': 'Rack PDU',
      'type': 'Power',
      'status': 'Active',
    });
    batch.insert('elements', {
      'id': 'elem-epics-1',
      'parent_node_id': 'Epics',
      'name': 'Sprint Backlog',
      'type': 'Planning',
      'status': 'Active',
    });
    batch.insert('elements', {
      'id': 'elem-traceability-1',
      'parent_node_id': 'Traceability',
      'name': 'Requirement Trace',
      'type': 'Compliance',
      'status': 'Active',
    });

    // alarms
    batch.insert('alarms', {
      'id': 'alarm-ingestion-1',
      'parent_node_id': 'Ingestion',
      'target': 'Telemetry DB',
      'severity': 'Critical',
      'timestamp': '2026-06-23',
    });
    batch.insert('alarms', {
      'id': 'alarm-metrics-1',
      'parent_node_id': 'Metrics',
      'target': 'High Latency',
      'severity': 'Warning',
      'timestamp': '2026-06-23',
    });
    batch.insert('alarms', {
      'id': 'alarm-location-1',
      'parent_node_id': 'Location',
      'target': 'Signal Loss',
      'severity': 'Critical',
      'timestamp': '2026-06-23',
    });
    batch.insert('alarms', {
      'id': 'alarm-chassis-1',
      'parent_node_id': 'Chassis',
      'target': 'Overcurrent',
      'severity': 'Critical',
      'timestamp': '2026-06-23',
    });
    batch.insert('alarms', {
      'id': 'alarm-epics-1',
      'parent_node_id': 'Epics',
      'target': 'Missed Milestone',
      'severity': 'Warning',
      'timestamp': '2026-06-23',
    });
    batch.insert('alarms', {
      'id': 'alarm-traceability-1',
      'parent_node_id': 'Traceability',
      'target': 'Gap Found',
      'severity': 'Critical',
      'timestamp': '2026-06-23',
    });

    // events
    batch.insert('events', {
      'id': 'event-ingestion-1',
      'parent_node_id': 'Ingestion',
      'source': 'System',
      'message': 'Console initialized',
      'timestamp': '2026-06-23',
    });
    batch.insert('events', {
      'id': 'event-metrics-1',
      'parent_node_id': 'Metrics',
      'source': 'Metrics',
      'message': 'Threshold breach',
      'timestamp': '2026-06-23',
    });
    batch.insert('events', {
      'id': 'event-location-1',
      'parent_node_id': 'Location',
      'source': 'Geo',
      'message': 'Coordinate update',
      'timestamp': '2026-06-23',
    });
    batch.insert('events', {
      'id': 'event-chassis-1',
      'parent_node_id': 'Chassis',
      'source': 'Chassis',
      'message': 'Power cycle',
      'timestamp': '2026-06-23',
    });
    batch.insert('events', {
      'id': 'event-epics-1',
      'parent_node_id': 'Epics',
      'source': 'Agile',
      'message': 'Epic created',
      'timestamp': '2026-06-23',
    });
    batch.insert('events', {
      'id': 'event-traceability-1',
      'parent_node_id': 'Traceability',
      'source': 'Compliance',
      'message': 'Trace updated',
      'timestamp': '2026-06-23',
    });

    await batch.commit(noResult: true);
  }
}
