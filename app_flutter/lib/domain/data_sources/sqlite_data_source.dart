import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:convert';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/domain/data_source.dart';

/// [DataSource] implementation backed by the local SQLite database.
///
/// Reads type definitions, attributes, and relations from the
/// `type_definitions`, `type_attributes`, and `type_relations` tables.
class SqliteDataSource implements DataSource {
  SqliteDataSource(this._db);
  final Database _db;

  @override
  String get name => 'sqlite';

  @override
  Future<List<TypeDescriptor>> discoverTypes() async {
    final typeRows = await _db.query('type_definitions');
    final types = <TypeDescriptor>[];
    for (final typeRow in typeRows) {
      types.add(await _buildType(typeRow));
    }
    return types;
  }

  @override
  Future<TypeDescriptor?> typeFor(String typeName) async {
    final rows = await _db.query('type_definitions',
        where: 'type_name = ?', whereArgs: [typeName]);
    if (rows.isEmpty) return null;
    return _buildType(rows.first);
  }

  Future<TypeDescriptor> _buildType(Map<String, dynamic> typeRow) async {
    final typeName = typeRow['type_name'] as String;
    final attrRows = await _db.query('type_attributes',
        where: 'type_name = ?',
        whereArgs: [typeName],
        orderBy: 'section_order, id');
    final relRows = await _db.query('type_relations',
        where: 'parent_type_name = ?', whereArgs: [typeName]);

    return TypeDescriptor(
      typeName: typeName,
      displayName: typeRow['display_name'] as String,
      iconName: typeRow['icon_name'] as String,
      fields: attrRows.map(_parseField).toList(),
      childTypes: relRows.map((r) => TypeRelationDescriptor(
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
