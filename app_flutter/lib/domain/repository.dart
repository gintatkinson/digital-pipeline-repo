import 'dart:async';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Abstract interface for data-access operations on nodes and their
/// properties, elements, alarms, and events.
abstract class AbstractRepository {
  /// Fetches the property map for the node identified by [nodeId].
  Future<Map<String, dynamic>> fetchProperties(String nodeId);

  /// Persists [data] as the properties for [nodeId].
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);

  /// Returns a broadcast stream that yields the current properties and
  /// then emits updates whenever properties change for [nodeId].
  Stream<Map<String, dynamic>> watchProperties(String nodeId);

  /// Fetches child elements of [parentNodeId].
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId);

  /// Fetches alarms associated with [parentNodeId].
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId);

  /// Fetches events associated with [parentNodeId].
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId);
}

/// SQLite-backed implementation of [AbstractRepository].
class SqliteRepositoryAdapter implements AbstractRepository {
  final Database db;
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Creates an adapter backed by the given [db].
  SqliteRepositoryAdapter(this.db);

  /// Queries the `properties` table for [nodeId] and decodes its JSON.
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'properties',
      columns: ['data_json'],
      where: 'node_id = ?',
      whereArgs: [nodeId],
    );

    if (maps.isEmpty) {
      return {};
    }

    final String? dataJson = maps.first['data_json'] as String?;
    if (dataJson == null) {
      return {};
    }

    try {
      return jsonDecode(dataJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Inserts or replaces properties JSON for [nodeId] and broadcasts update.
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    final String dataJson = jsonEncode(data);
    await db.insert(
      'properties',
      {'node_id': nodeId, 'data_json': dataJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _controller.add({
      'nodeId': nodeId,
      'data': data,
    });
  }

  /// Yields current properties then streams live updates for [nodeId].
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield await fetchProperties(nodeId);
    await for (final event in _controller.stream) {
      if (event['nodeId'] == nodeId) {
        yield event['data'] as Map<String, dynamic>;
      }
    }
  }

  /// Queries the `elements` table by [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async {
    return await db.query(
      'elements',
      where: 'parent_node_id = ?',
      whereArgs: [parentNodeId],
    );
  }

  /// Queries the `alarms` table by [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async {
    return await db.query(
      'alarms',
      where: 'parent_node_id = ?',
      whereArgs: [parentNodeId],
    );
  }

  /// Queries the `events` table by [parentNodeId].
  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async {
    return await db.query(
      'events',
      where: 'parent_node_id = ?',
      whereArgs: [parentNodeId],
    );
  }
}
