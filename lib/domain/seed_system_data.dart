import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Configuration for deterministic, formula-derived test data generation.
///
/// All names (types, attributes, sections, relations, node IDs) are
/// derived from indices — zero hardcoded domain knowledge. Tune the
/// counts to scale the integration test dataset.
class SeedConfig {
  final int typeCount;
  final int masterCount;
  final int attributesPerType;
  final int sectionsPerType;
  final int relationCountPerType;
  final int rowsPerRelation;

  const SeedConfig({
    required this.typeCount,
    required this.masterCount,
    required this.attributesPerType,
    required this.sectionsPerType,
    required this.relationCountPerType,
    required this.rowsPerRelation,
  });
}

/// Populates [db] with synthetic types, attributes, relations,
/// instances, and child entries using formula-derived identifiers.
///
/// Clears all five tables before inserting. Child entries use batch
/// operations chunked at 500 rows to avoid memory pressure with large
/// [SeedConfig.rowsPerRelation] values.
///
/// Expected counts for the default config (8, 100, 50, 5, 3, 90):
/// type_definition=8, type_attribute=400, type_relation=24,
/// instance=100, child_entry=27,000.
Future<void> seedSystemData(Database db, SeedConfig config) async {
  final tc = config.typeCount;
  final mc = config.masterCount;
  final apc = config.attributesPerType;
  final rc = config.relationCountPerType;
  final rr = config.rowsPerRelation;

  const icons = [
    'data_object',
    'folder',
    'insert_drive_file',
    'label',
    'settings',
    'storage',
    'cloud',
    'dns',
  ];

  const fieldTypeCycle = [
    'string', 'int_', 'double_', 'enum_', 'date', 'bool_',
  ];

  const labelPrefix = {
    'string': 'S',
    'int_': 'I',
    'double_': 'D',
    'enum_': 'E',
    'date': 'T',
    'bool_': 'B',
  };

  final enumJson = jsonEncode(['op_0', 'op_1', 'op_2']);

  await db.delete('child_entry');
  await db.delete('instance');
  await db.delete('type_relation');
  await db.delete('type_attribute');
  await db.delete('type_definition');

  for (var ti = 0; ti < tc; ti++) {
    await db.insert('type_definition', {
      'type_name': 'Type$ti',
      'display_name': 'Type $ti',
      'icon_name': icons[ti % icons.length],
    });
  }

  for (var ti = 0; ti < tc; ti++) {
    for (var ai = 0; ai < apc; ai++) {
      final num = (ai + 1).toString().padLeft(2, '0');
      final ft = fieldTypeCycle[ai % fieldTypeCycle.length];
      final sectionIndex = ai * 5 ~/ apc;
      final sectionLabel = 'G_${(sectionIndex + 1).toString().padLeft(2, '0')}';
      await db.insert('type_attribute', {
        'type_name': 'Type$ti',
        'attr_key': 'attr_$num',
        'label': '${labelPrefix[ft]}_$num',
        'attr_type': ft,
        'section_label': sectionLabel,
        'section_order': sectionIndex,
        'is_required': 1,
        'min_value': ft == 'int_' ? 0 : null,
        'max_value': ft == 'int_' ? 999999 : null,
        'pattern': null,
        'enum_options': ft == 'enum_' ? enumJson : null,
        'enum_display_names': null,
        'default_value': null,
        'input_formatters': null,
      });
    }
  }

  final typeRelations = <int, List<Map<String, String>>>{};
  for (var ti = 0; ti < tc; ti++) {
    final rels = <Map<String, String>>[];
    for (var ri = 0; ri < rc; ri++) {
      final target = (ti + ri + 1) % tc;
      rels.add({
        'relation_name': 'relates_to_Type$target',
        'child_type_name': 'Type$target',
        'child_label': 'Type $target Records',
      });
      await db.insert('type_relation', {
        'parent_type_name': 'Type$ti',
        'relation_name': 'relates_to_Type$target',
        'child_type_name': 'Type$target',
        'child_label': 'Type $target Records',
      });
    }
    typeRelations[ti] = rels;
  }

  final floorCount = mc ~/ tc;
  final remainder = mc % tc;
  final typeCounts = <int, int>{};
  final typeStartIndex = <int, int>{};
  var runningIdx = 0;
  for (var ti = 0; ti < tc; ti++) {
    final cnt = ti < remainder ? floorCount + 1 : floorCount;
    typeCounts[ti] = cnt;
    typeStartIndex[ti] = runningIdx;
    runningIdx += cnt;
  }

  final attrMeta = <int, Map<String, dynamic>>{};
  for (var ai = 0; ai < apc; ai++) {
    attrMeta[ai] = {
      'key': 'attr_${(ai + 1).toString().padLeft(2, '0')}',
      'type': fieldTypeCycle[ai % fieldTypeCycle.length],
    };
  }

  for (var ti = 0; ti < tc; ti++) {
    final cnt = typeCounts[ti]!;
    final startIdx = typeStartIndex[ti]!;
    for (var c = 0; c < cnt; c++) {
      final globalIndex = startIdx + c;
      final nodeId = 'Type$ti-${c.toString().padLeft(3, '0')}';
      final data = <String, dynamic>{};

      for (var ai = 0; ai < apc; ai++) {
        final meta = attrMeta[ai]!;
        final key = meta['key'] as String;
        final ft = meta['type'] as String;
        switch (ft) {
          case 'string':
            data[key] = 'v_${nodeId}_$key';
          case 'int_':
            data[key] = globalIndex * 100 + ai;
          case 'double_':
            data[key] = globalIndex + ai * 0.1;
          case 'enum_':
            data[key] = 'op_0';
          case 'date':
            data[key] = '2026-01-01';
          case 'bool_':
            data[key] = (globalIndex + ai) % 2 == 0;
        }
      }

      await db.insert('instance', {
        'node_id': nodeId,
        'data_json': jsonEncode(data),
      });
    }
  }

  var batch = db.batch();
  var batchCount = 0;

  for (var ti = 0; ti < tc; ti++) {
    final cnt = typeCounts[ti]!;
    final rels = typeRelations[ti]!;
    for (var c = 0; c < cnt; c++) {
      final nodeId = 'Type$ti-${c.toString().padLeft(3, '0')}';
      for (final rel in rels) {
        final rn = rel['relation_name']!;
        for (var ei = 0; ei < rr; ei++) {
          final eNum = (ei + 1).toString().padLeft(2, '0');
          final childId = 'ce_${nodeId}_${rn}_$eNum';
          final payload = jsonEncode({
            'col_0': 'r_${nodeId}_${rn}_${ei + 1}',
            'col_1': ei,
            'col_2': ei * 10.0,
          });
          batch.insert('child_entry', {
            'id': childId,
            'parent_node_id': nodeId,
            'relation_name': rn,
            'payload_json': payload,
          });
          batchCount++;
          if (batchCount >= 500) {
            await batch.commit(noResult: true);
            batch = db.batch();
            batchCount = 0;
          }
        }
      }
    }
  }

  if (batchCount > 0) {
    await batch.commit(noResult: true);
  }
}
