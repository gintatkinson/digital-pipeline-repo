import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/string_resources.dart';
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/data_sources/sqlite_data_source.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Performance Profiling Test Suite', () {
    testWidgets('3D Viewport Stress Test - Timeline', (WidgetTester tester) async {
      // 1. Setup SQLite Database
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dbPath = p.join(Directory.systemTemp.path, 'perf_test.db');
      final file = File(dbPath);
      if (file.existsSync()) file.deleteSync();

      final db = await DatabaseInitializer.create(dbPath: dbPath, seed: false);

      // 2. Seed 500 ground nodes, 100 space nodes, and 200 links
      final batch = db.batch();
      
      // Ground nodes
      for (int i = 0; i < 500; i++) {
        batch.insert('properties', {
          'node_id': 'ground_$i',
          'parent_node_id': null,
          'data_json': jsonEncode({
            'name': 'Ground Node $i',
            'type': 'ground',
            'latitude': 30.0 + (i % 20) * 0.1,
            'longitude': -90.0 + (i % 25) * 0.1,
            'altitude': 0.0,
            'status': 'Active',
          }),
        });
      }

      // Space nodes
      for (int i = 0; i < 100; i++) {
        batch.insert('properties', {
          'node_id': 'space_$i',
          'parent_node_id': null,
          'data_json': jsonEncode({
            'name': 'Space Node $i',
            'type': 'space',
            'latitude': 40.0 + (i % 10) * 0.2,
            'longitude': -100.0 + (i % 10) * 0.2,
            'altitude': 500000.0,
            'status': 'Active',
          }),
        });
      }

      // 200 links
      for (int i = 0; i < 200; i++) {
        final source = 'ground_${i % 500}';
        final target = i < 100 ? 'space_$i' : 'ground_${(i + 10) % 500}';
        batch.insert('instances', {
          'id': 'link_$i',
          'parent_node_id': source,
          'type_name': 'interface',
          'data_json': jsonEncode({
            'description': 'link to node $target',
          }),
        });
      }

      await batch.commit(noResult: true);
      final dataSource = SqliteDataSource(db);

      // 3. Mount the application
      final themeService = SharedPreferencesThemeService();
      final themeController = ThemeController(themeService);
      await themeController.loadSettings();

      final textScalerController = TextScalerController(themeService);
      await textScalerController.load();

      app.globalThemeController = themeController;
      app.globalTextScalerController = textScalerController;

      await StringResources.load();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DataSource>.value(value: dataSource),
            ChangeNotifierProvider<ThemeController>.value(value: themeController),
            ChangeNotifierProvider<TextScalerController>.value(value: textScalerController),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 4. Trace the interaction script
      await binding.traceAction(() async {
        final center = tester.getCenter(find.byType(MaterialApp));

        // Rapid pointer scrolls (zooming)
        for (int i = 0; i < 3; i++) {
          final gesture = await tester.startGesture(center);
          await gesture.moveBy(const Offset(0, -100));
          await tester.pump(const Duration(milliseconds: 50));
          await gesture.moveBy(const Offset(0, 100));
          await tester.pump(const Duration(milliseconds: 50));
          await gesture.up();
        }

        // Aggressive pointer panning (simulating rotating the globe)
        for (int i = 0; i < 5; i++) {
          await tester.dragFrom(center, const Offset(-200, 50));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.dragFrom(center, const Offset(200, -50));
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Visually iterate through each node in the tree and trigger fly-to-node
        for (int i = 0; i < 5; i++) {
           final nodeFinder = find.text('Ground Node $i');
           if (nodeFinder.evaluate().isNotEmpty) {
             await tester.tap(nodeFinder.first);
             for (int j = 0; j < 10; j++) {
               await tester.pump(const Duration(milliseconds: 50));
             }
           }
        }
      }, reportKey: 'viewport_perf');

      // 5. Output and Thresholds
      final reportData = binding.reportData;
      if (reportData != null && reportData.containsKey('viewport_perf')) {
        final rawTimeline = reportData['viewport_perf'];
        final timeline = driver.Timeline.fromJson(rawTimeline as Map<String, dynamic>);
        final summary = driver.TimelineSummary.summarize(timeline);

        await summary.writeTimelineToFile('viewport_perf', pretty: true);

        // Strict pass/fail criteria to prevent regressions
        expect(
          summary.computeAverageFrameBuildTimeMillis(),
          lessThan(16.0),
          reason: 'Average frame build time must be < 16.0ms for 60 FPS.',
        );
        expect(
          summary.computePercentileFrameBuildTimeMillis(90.0),
          lessThan(16.6),
          reason: '90th percentile frame build time must be < 16.6ms for 60 FPS.',
        );
        expect(
          summary.computeAverageFrameRasterizerTimeMillis(),
          lessThan(16.0),
          reason: 'Average frame rasterizer time must be < 16.0ms for 60 FPS.',
        );
      } else {
        fail('Timeline data was not captured');
      }
    });
  });
}
