import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data_source.dart';
import 'type_descriptor.dart';

class SqliteDataSource implements DataSource {
  final Database db;

  SqliteDataSource(this.db);

  @override
  String get name => 'sqlite';

  FieldType _parseFieldType(String raw) {
    switch (raw) {
      case 'string':
        return FieldType.string;
      case 'int_':
        return FieldType.int_;
      case 'double_':
        return FieldType.double_;
      case 'enum_':
        return FieldType.enum_;
      case 'date':
        return FieldType.date;
      case 'bool_':
        return FieldType.bool_;
      default:
        return FieldType.string;
    }
  }

  List<String>? _parseJsonList(String? raw) {
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
    return null;
  }

  Map<String, dynamic>? _parseJsonMap(String? raw) {
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  dynamic _parseDefaultValue(String? raw, FieldType type) {
    if (raw == null) return null;
    switch (type) {
      case FieldType.int_:
        return int.tryParse(raw);
      case FieldType.double_:
        return double.tryParse(raw);
      case FieldType.bool_:
        return raw == 'true' || raw == '1';
      default:
        return raw;
    }
  }

  Future<List<FieldDescriptor>> _fetchFieldDescriptors(String typeName) async {
    final rows = await db.query(
      'type_attribute',
      where: 'type_name = ?',
      whereArgs: [typeName],
    );
    return rows.map((row) {
      final fieldType = _parseFieldType(row['attr_type'] as String);
      return FieldDescriptor(
        key: row['attr_key'] as String,
        label: row['label'] as String,
        type: fieldType,
        sectionLabel: row['section_label'] as String?,
        sectionOrder: row['section_order'] as int? ?? 0,
        required: (row['is_required'] as int?) == 1,
        minValue: row['min_value'] as num?,
        maxValue: row['max_value'] as num?,
        pattern: row['pattern'] as String?,
        enumOptions: _parseJsonList(row['enum_options'] as String?),
        enumDisplayNames: _parseJsonList(row['enum_display_names'] as String?),
        defaultValue: _parseDefaultValue(
          row['default_value'] as String?,
          fieldType,
        ),
        inputFormatters: _parseJsonList(row['input_formatters'] as String?),
      );
    }).toList();
  }

  Future<List<TypeRelationDescriptor>> _fetchChildTypes(
    String typeName,
  ) async {
    final rows = await db.query(
      'type_relation',
      where: 'parent_type_name = ?',
      whereArgs: [typeName],
    );
    return rows.map((row) {
      return TypeRelationDescriptor(
        relationName: row['relation_name'] as String,
        targetTypeName: row['child_type_name'] as String,
        displayLabel: row['child_label'] as String,
      );
    }).toList();
  }

  Future<List<TypeRelationDescriptor>> _fetchParentTypes(
    String typeName,
  ) async {
    final rows = await db.query(
      'type_relation',
      where: 'child_type_name = ?',
      whereArgs: [typeName],
    );
    return rows.map((row) {
      return TypeRelationDescriptor(
        relationName: row['relation_name'] as String,
        targetTypeName: row['parent_type_name'] as String,
        displayLabel: row['child_label'] as String,
      );
    }).toList();
  }

  Future<TypeDescriptor> _buildTypeDescriptor(
    Map<String, dynamic> row,
  ) async {
    final typeName = row['type_name'] as String;
    final fields = await _fetchFieldDescriptors(typeName);
    final childTypes = await _fetchChildTypes(typeName);
    final parentTypes = await _fetchParentTypes(typeName);
    return TypeDescriptor(
      typeName: typeName,
      displayName: row['display_name'] as String,
      iconName: row['icon_name'] as String,
      fields: fields,
      childTypes: childTypes,
      parentTypes: parentTypes,
    );
  }

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final rows = await db.query('type_definition');
    final descriptors = <TypeDescriptor>[];
    for (final row in rows) {
      descriptors.add(await _buildTypeDescriptor(row));
    }
    return descriptors;
  }

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final rows = await db.query(
      'type_definition',
      where: 'type_name = ?',
      whereArgs: [typeName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _buildTypeDescriptor(rows.first);
  }

  @override
  Future<List<InstanceDescriptor>> discoverInstances() async {
    final instanceRows = await db.query('instance');
    final typeDefRows = await db.query('type_definition');
    final typeDisplayNames = <String, String>{};
    for (final row in typeDefRows) {
      typeDisplayNames[row['type_name'] as String] =
          row['display_name'] as String;
    }
    return instanceRows.map((row) {
      final nodeId = row['node_id'] as String;
      final lastDash = nodeId.lastIndexOf('-');
      final typeName = lastDash > 0 ? nodeId.substring(0, lastDash) : nodeId;
      final displayName = typeDisplayNames[typeName] ?? typeName;
      return InstanceDescriptor(
        nodeId: nodeId,
        typeName: typeName,
        displayLabel: '$displayName $nodeId',
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> fetchProperties(String nodeId) async {
    final rows = await db.query(
      'instance',
      where: 'node_id = ?',
      whereArgs: [nodeId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _parseJsonMap(rows.first['data_json'] as String?);
  }

  @override
  Future<void> saveProperties(
    String nodeId,
    Map<String, dynamic> data,
  ) async {
    final encoded = jsonEncode(data);
    await db.insert(
      'instance',
      {'node_id': nodeId, 'data_json': encoded},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchChildren(
    String nodeId,
    String relationName,
  ) async {
    final rows = await db.query(
      'child_entry',
      where: 'parent_node_id = ? AND relation_name = ?',
      whereArgs: [nodeId, relationName],
    );
    return rows.map((row) {
      final payload =
          _parseJsonMap(row['payload_json'] as String?) ?? {};
      return {
        'id': row['id'],
        'parent_node_id': row['parent_node_id'],
        'relation_name': row['relation_name'],
        ...payload,
      };
    }).toList();
  }
}
