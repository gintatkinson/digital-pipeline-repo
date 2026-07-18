import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/database_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseInitializer spatial seeding', () {
    test('seeded root nodes have height=100.0 and non-root have height=0.0', () async {
      final db = await DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: true);

      final rows = await db.query('properties');
      expect(rows.length, greaterThan(0));

      for (final row in rows) {
        final nodeId = row['node_id'] as String;
        final data = jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>;
        final ellipsoid = location['ellipsoid'] as Map<String, dynamic>;
        final height = ellipsoid['height'] as num;

        if (nodeId.startsWith('Master_') && !nodeId.contains('_Child_') && !nodeId.contains('_Grandchild_')) {
          expect(height, 100.0,
              reason: 'Root node $nodeId should have height 100.0 but got $height');
        } else {
          expect(height, 0.0,
              reason: 'Non-root node $nodeId should have height 0.0 but got $height');
        }
      }

      await db.close();
    });

    test('seeded nodes have non-identical coordinates (no collision)', () async {
      final db = await DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: true);

      final rows = await db.query('properties');
      expect(rows.length, greaterThan(1));

      final coords = <String>{};
      for (final row in rows) {
        final data = jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>;
        final ellipsoid = location['ellipsoid'] as Map<String, dynamic>;
        final lat = ellipsoid['latitude'] as num;
        final lon = ellipsoid['longitude'] as num;
        final height = ellipsoid['height'] as num;
        coords.add('$lat,$lon,$height');
      }

      expect(coords.length, greaterThan(1),
          reason: 'Expected non-identical coordinates but all $coords are the same');

      await db.close();
    });
  });
}
