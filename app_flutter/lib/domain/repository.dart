import 'dart:async';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class AbstractRepository {
  Future<Map<String, dynamic>> fetchProperties(String nodeId);
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);
  Stream<Map<String, dynamic>> watchProperties(String nodeId);
}

class SqliteRepositoryAdapter implements AbstractRepository {
  final Database db;
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  SqliteRepositoryAdapter(this.db);

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

  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield await fetchProperties(nodeId);
    await for (final event in _controller.stream) {
      if (event['nodeId'] == nodeId) {
        yield event['data'] as Map<String, dynamic>;
      }
    }
  }
}
