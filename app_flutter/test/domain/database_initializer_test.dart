import 'dart:convert';
import 'dart:io';

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
    test('regenerate assets database', () async {
      final dbPath = 'assets/properties_db.db';
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }
      final db = await DatabaseInitializer.create(dbPath: dbPath, seed: true);
      await db.close();

      final gzFile = File('assets/properties_db.db.gz');
      if (await gzFile.exists()) {
        await gzFile.delete();
      }
      final bytes = await file.readAsBytes();
      final gzipped = gzip.encode(bytes);
      await gzFile.writeAsBytes(gzipped);
      expect(await gzFile.exists(), isTrue);
    });

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

      expect(coords.length, rows.length,
          reason: 'Expected all ${rows.length} nodes to have unique coordinates but only ${coords.length} are distinct');

      await db.close();
    });

    test('non-root coordinate offsets populate all 4 quadrants', () async {
      final db = await DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: true);

      final rows = await db.query('properties');
      final Map<String, (double, double)> rootCoords = {};
      final List<(String, double, double)> nonRootCoords = [];

      for (final row in rows) {
        final nodeId = row['node_id'] as String;
        final data = jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>;
        final ellipsoid = location['ellipsoid'] as Map<String, dynamic>;
        final lat = (ellipsoid['latitude'] as num).toDouble();
        final lon = (ellipsoid['longitude'] as num).toDouble();
        final height = (ellipsoid['height'] as num).toDouble();

        if (height == 100.0) {
          rootCoords[nodeId] = (lat, lon);
        } else {
          nonRootCoords.add((nodeId, lat, lon));
        }
      }

      expect(rootCoords.isNotEmpty, isTrue);
      expect(nonRootCoords.isNotEmpty, isTrue);

      final Set<String> quadrantsHit = {};
      for (final (nodeId, lat, lon) in nonRootCoords) {
        final rootId = nodeId.split('_Child_').first;
        final root = rootCoords[rootId];
        if (root == null) continue;
        final (rootLat, rootLon) = root;

        final latSign = lat > rootLat ? '+' : (lat < rootLat ? '-' : '0');
        final lonSign = lon > rootLon ? '+' : (lon < rootLon ? '-' : '0');
        if (latSign != '0' && lonSign != '0') {
          quadrantsHit.add('$latSign$lonSign');
        }
      }

      expect(quadrantsHit, containsAll(['++', '+-', '-+', '--']),
          reason: 'Expected nodes in all 4 quadrants but found ${quadrantsHit.length}: $quadrantsHit');

      await db.close();
    });
  });
}
