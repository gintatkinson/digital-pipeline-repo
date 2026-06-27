import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'schema.dart';

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

    await db.execute(
      'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
    );

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
    final layoutJson =
        await rootBundle.loadString('assets/logical-layout.json');
    final layoutConfig = jsonDecode(layoutJson) as Map<String, dynamic>;

    final nodes = _extractNodeIds(layoutConfig);
    final defaultMap = _computeDefaults(layoutConfig);
    final defaultJson = jsonEncode(defaultMap);

    for (final node in nodes) {
      await db.insert('properties', {
        'node_id': node,
        'data_json': defaultJson,
      });
    }
  }

  static List<String> _extractNodeIds(Map<String, dynamic> layoutConfig) {
    final layoutMap = layoutConfig['layout'] as Map<String, dynamic>?;
    final rootContainer = layoutMap?['root_container'] as Map<String, dynamic>?;
    final children = rootContainer?['children'] as List<dynamic>?;
    List<dynamic>? hierarchy;
    if (children != null) {
      for (final child in children) {
        if (child is Map<String, dynamic> &&
            child['type'] == 'HierarchyTreeSelector') {
          final props = child['props'] as Map<String, dynamic>?;
          hierarchy = props?['hierarchy'] as List<dynamic>?;
          break;
        }
      }
    }

    final List<String> nodes = [];
    void traverse(List<dynamic>? items) {
      if (items == null) return;
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          final id = item['id'];
          if (id is String) {
            nodes.add(id);
          }
          final nested = item['children'];
          if (nested is List<dynamic>) {
            traverse(nested);
          }
        }
      }
    }
    traverse(hierarchy);
    return nodes;
  }

  static Map<String, dynamic> _computeDefaults(
      Map<String, dynamic> layoutConfig) {
    final attributes = layoutConfig['attributes'] as List<dynamic>? ?? [];
    final defaultMap = <String, dynamic>{};
    for (final attr in attributes) {
      if (attr is Map<String, dynamic>) {
        final definition = AttributeDefinition.fromJson(attr);
        defaultMap[definition.key] = definition.defaultValue;
      }
    }
    return defaultMap;
  }
}
