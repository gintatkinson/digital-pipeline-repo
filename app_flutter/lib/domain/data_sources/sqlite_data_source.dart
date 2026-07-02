import 'dart:async';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/instance_record.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/domain/data_source.dart';

/// [DataSource] implementation backed by the local SQLite database.
///
/// Reads type definitions, attributes, and relations from the
/// `type_definitions`, `type_attributes`, and `type_relations` tables.
/// Instance data resides in `properties`, `elements`, `alarms`, and
/// `events` tables. Use this data source for offline-first or
/// single-user deployments where no remote backend is available.
/// The database is assumed to be already opened and migrated; no
/// schema creation is performed here. All reads hit the database
/// directly — results are NOT cached.
class SqliteDataSource implements DataSource {
  SqliteDataSource(this._db);
  final Database _db;
  final StreamController<Map<String, dynamic>> _propertiesController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  String get name => 'sqlite';

  /// Reads all type definitions from the `type_definitions` table and
  /// hydrates each row into a [TypeDescriptor] by joining into
  /// `type_attributes` and `type_relations`.
  ///
  /// Returns an empty list when the table is empty (e.g. first launch
  /// before schema is seeded). Each call triggers at least
  /// (1 + N) SQL queries where N is the row count — use sparingly in
  /// hot paths. Does NOT throw on missing data; missing foreign rows
  /// simply produce empty fields/childTypes.
  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final typeRows = await _db.query('type_definitions');
    final types = <TypeDescriptor>[];
    for (final typeRow in typeRows) {
      types.add(await _buildType(typeRow));
    }
    return types;
  }

  /// Queries `type_definitions` for a single row matching [typeName]
  /// and builds a [TypeDescriptor] from its attributes and relations.
  ///
  /// Returns `null` when [typeName] does not exist (e.g. a legacy
  /// node references a removed type). Throws if the row exists but
  /// `type_name` is null.
  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final rows = await _db.query('type_definitions',
        where: 'type_name = ?', whereArgs: [typeName]);
    if (rows.isEmpty) return null;
    return _buildType(rows.first);
  }

  /// Reads all parent-child type pairs from the `type_relations` table.
  ///
  /// Returns an empty list when no relations are defined (e.g. a flat
  /// ontology with no hierarchy). Each call triggers a full table
  /// scan — consider caching if the hierarchy is static.
  @override
  Future<List<(String, String)>> discoverHierarchy() async {
    final rows = await _db.query('type_relations');
    return rows.map((r) => (
      r['parent_type_name'] as String,
      r['child_type_name'] as String,
    )).toList();
  }

  /// Fetches the property map for the node identified by [nodeId]
  /// from the `properties` table.
  ///
  /// Returns an empty map when the node has no row (e.g. a newly
  /// created node that has never been saved) or when the stored
  /// `data_json` is null or malformed. Malformed JSON is silently
  /// caught and returns `{}` so the caller can present a blank form
  /// instead of crashing. Each call executes a single SELECT.
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async {
    final maps = await _db.query(
      'properties',
      columns: ['data_json'],
      where: 'node_id = ?',
      whereArgs: [nodeId],
    );
    if (maps.isEmpty) return {};
    final dataJson = maps.first['data_json'] as String?;
    if (dataJson == null) return {};
    try {
      return jsonDecode(dataJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Persists [data] as the properties for [nodeId] in the
  /// `properties` table using an upsert (replace on conflict).
  ///
  /// STATE CHANGE: Writes to the `properties` table and emits a
  /// change event on the broadcast stream so all active
  /// [watchProperties] subscribers receive the update. Use this for
  /// both creates and updates — the upsert handles both transparently.
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {
    final dataJson = jsonEncode(data);
    await _db.insert(
      'properties',
      {'node_id': nodeId, 'data_json': dataJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _propertiesController.add({'nodeId': nodeId, 'data': data});
  }

  /// Returns a broadcast stream that first emits the current
  /// properties for [nodeId] (via [fetchProperties]) and then yields
  /// subsequent updates whenever [saveProperties] is called for the
  /// same [nodeId].
  ///
  /// The initial yield is synchronous — callers receive the current
  /// state immediately upon subscription. Subscriptions that outlive
  /// the data source will receive events indefinitely; cancel the
  /// subscription to avoid leaks.
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) async* {
    yield await fetchProperties(nodeId);
    await for (final event in _propertiesController.stream) {
      if (event['nodeId'] == nodeId) {
        yield event['data'] as Map<String, dynamic>;
      }
    }
  }

  @override
  Future<List<InstanceRecord>> fetchRelatedInstances({
    required String parentNodeId,
    required TypeDescriptor targetType,
  }) async {
    final rows = await _db.query(
      'instances',
      where: 'parent_node_id = ? AND type_name = ?',
      whereArgs: [parentNodeId, targetType.typeName],
    );
    return rows.map((r) => InstanceRecord.fromMap(r, targetType.typeName)).toList();
  }

  Future<TypeDescriptor> _buildType(Map<String, dynamic> typeRow) async {
    final typeName = typeRow['type_name'] as String;
    final attrRows = await _db.query('type_attributes',
        where: 'type_name = ?',
        whereArgs: [typeName],
        orderBy: 'section_order, id');
    final relRows = await _db.query('type_relations',
        where: 'parent_type_name = ?', whereArgs: [typeName]);

    final childRows = relRows.where((r) => r['relation_name'] == 'contains');
    final relatedRows = relRows.where((r) => r['relation_name'] != 'contains');

    return TypeDescriptor(
      typeName: typeName,
      displayName: typeRow['display_name'] as String,
      iconName: typeRow['icon_name'] as String,
      fields: attrRows.map(_parseField).toList(),
      childTypes: childRows.map((r) => TypeRelationDescriptor(
        relationName: r['relation_name'] as String,
        childTypeName: r['child_type_name'] as String,
        childLabel: r['child_label'] as String,
      )).toList(),
      relatedTypes: relatedRows.map((r) => TypeRelationDescriptor(
        relationName: r['relation_name'] as String,
        childTypeName: r['child_type_name'] as String,
        childLabel: r['child_label'] as String,
      )).toList(),
      parentTypes: [], // populated by caller if needed
    );
  }

  FieldDescriptor _parseField(Map<String, dynamic> row) {
    List<String>? parseJsonList(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return (jsonDecode(raw) as List).cast<String>();
    }

    return FieldDescriptor(
      key: row['attr_key'] as String,
      label: row['label'] as String,
      type: row['attr_type'] as String,
      sectionLabel: row['section_label'] as String?,
      sectionOrder: row['section_order'] as int? ?? 0,
      required: (row['is_required'] as int? ?? 0) == 1,
      minValue: row['min_value'] as num?,
      maxValue: row['max_value'] as num?,
      pattern: row['pattern'] as String?,
      enumOptions: parseJsonList(row['enum_options'] as String?),
      enumDisplayNames: parseJsonList(row['enum_display_names'] as String?),
      defaultValue: row['default_value'],
      inputFormatters: parseJsonList(row['input_formatters'] as String?),
    );
  }
}
