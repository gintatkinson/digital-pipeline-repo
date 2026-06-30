import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Abstract interface for data-access operations on nodes and their
/// properties, elements, alarms, and events.
///
/// Separates the data-persistence concern from the UI and business-logic
/// layers. The app selects one implementation at startup (SQLite, Firebase)
/// and all consumers program against this interface — swapping the backend
/// requires no other code changes. Implementations must be stateless with
/// respect to data (they hold only connection state, not cached results).
abstract class AbstractRepository {
  /// Fetches the property map for the node identified by [nodeId].
  ///
  /// Returns an empty map when [nodeId] does not exist or has no properties.
  /// Never throws. The caller should treat an empty map as "no data" and
  /// render the form with default/empty inputs.
  Future<Map<String, dynamic>> fetchProperties(String nodeId);

  /// Persists [data] as the properties for [nodeId].
  ///
  /// Performs a full replacement of the property set for [nodeId].
  /// After a successful save, [watchProperties] subscribers receive
  /// the updated data automatically. An empty [data] map clears all
  /// properties — callers must pass the complete map, not a diff.
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);

  /// Returns a broadcast stream that yields the current properties and
  /// then emits updates whenever properties change for [nodeId].
  ///
  /// The initial emission is the result of [fetchProperties], so callers
  /// do not need to fetch separately. The stream stays open until the
  /// repository is disposed. If [nodeId] does not exist, the stream
  /// emits an empty map first and continues watching for future saves.
  Stream<Map<String, dynamic>> watchProperties(String nodeId);

  /// Fetches child elements of [parentNodeId].
  ///
  /// Returns an empty list when [parentNodeId] has no children or does
  /// not exist. Never throws.
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId);

  /// Fetches alarms associated with [parentNodeId].
  ///
  /// Returns an empty list when no alarms exist. Never throws.
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId);

  /// Fetches events associated with [parentNodeId].
  ///
  /// Returns an empty list when no events exist. Never throws.
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId);
}

/// SQLite-backed implementation of [AbstractRepository].
///
/// Reads and writes to a local SQLite database via `sqflite`. Properties
/// are stored as JSON blobs in a `properties` table. Elements, alarms,
/// and events live in their own tables keyed by `parent_node_id`.
///
/// Use this for offline-first or desktop deployments. It is the default
/// adapter when no explicit data-source type is configured. The database
/// must already have the expected table schemas — see [DatabaseInitializer]
/// for creating a new database.
class SqliteRepositoryAdapter implements AbstractRepository {
  final Database db;
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Creates an adapter backed by the given [db].
  ///
  /// The [db] must be open and have the `properties`, `elements`, `alarms`,
  /// and `events` tables already created. Passing a closed or invalid
  /// database causes operations to throw [DatabaseException].
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

/// Firestore-backed implementation of [AbstractRepository].
class FirebaseRepositoryAdapter implements AbstractRepository {
  final FirebaseFirestore firestore;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  FirebaseRepositoryAdapter(this.firestore);

  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    final doc = await firestore.collection('data').doc(nodeId).get();
    final data = doc.data();
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    await firestore.collection('data').doc(nodeId).set(data, SetOptions(merge: true));
    _controller.add({'nodeId': nodeId, 'data': data});
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

  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async {
    final snapshot = await firestore
        .collection('elements')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async {
    final snapshot = await firestore
        .collection('alarms')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async {
    final snapshot = await firestore
        .collection('events')
        .where('parent_node_id', isEqualTo: parentNodeId)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
