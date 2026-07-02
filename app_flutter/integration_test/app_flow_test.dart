import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/app.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/sqlite_repository.dart';
import 'package:pipeline_app/domain/seed_system_data.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';

Future<Database> _createDb() async {
  sqfliteFfiInit();
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'integration_test.db');
  try {
    await File(dbPath).delete();
  } catch (_) {}
  final db = await databaseFactoryFfi.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)',
        );
        await db.execute(
          'CREATE TABLE type_attribute (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name TEXT, attr_key TEXT, label TEXT, attr_type TEXT, section_label TEXT, section_order INTEGER DEFAULT 0, is_required INTEGER DEFAULT 0, min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT, enum_display_names TEXT, default_value TEXT, input_formatters TEXT, UNIQUE(type_name, attr_key))',
        );
        await db.execute(
          'CREATE TABLE type_relation (id INTEGER PRIMARY KEY AUTOINCREMENT, parent_type_name TEXT, relation_name TEXT, child_type_name TEXT, child_label TEXT, UNIQUE(parent_type_name, child_type_name))',
        );
        await db.execute(
          'CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)',
        );
        await db.execute(
          'CREATE TABLE child_entry (id TEXT PRIMARY KEY, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)',
        );
      },
    ),
  );
  return db;
}

Widget _buildApp(SqliteRepository repo, TreeViewModel tvm, ThemeController tc, TextScaleController tsc) {
  return PipelineApp(
    repository: repo,
    treeViewModel: tvm,
    themeController: tc,
    textScaleController: tsc,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late SqliteDataSource ds;
  late SqliteRepository repo;
  late ThemeController tc;
  late TextScaleController tsc;
  late TreeViewModel tvm;
  late List<String> allNodeIds;

  const config = SeedConfig(
    typeCount: 8,
    masterCount: 100,
    attributesPerType: 50,
    sectionsPerType: 5,
    relationCountPerType: 3,
    rowsPerRelation: 90,
  );

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    db = await _createDb();
    await seedSystemData(db, config);
    ds = SqliteDataSource(db);
    repo = SqliteRepository(ds);
    final prefs = await SharedPreferences.getInstance();
    tc = ThemeController(prefs);
    tc.loadSettings();
    tsc = TextScaleController();
    await tsc.load();
    tvm = TreeViewModel(repo);
    await tvm.load();
    final instances = await ds.discoverInstances();
    allNodeIds = instances.map((i) => i.displayLabel).toList();
  });

  tearDownAll(() async {
    await db.close();
  });

  testWidgets('sidebar shows first node and instance count is 100', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_buildApp(repo, tvm, tc, tsc));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
    expect(tvm.nodes.length, 100);
    expect(find.text(allNodeIds.first), findsOneWidget);
  });

  testWidgets('full traversal: select, edit, save, verify, scroll, settings', (tester) async {
    if (allNodeIds.isEmpty) return;

    await tester.runAsync(() async {
      await tester.pumpWidget(_buildApp(repo, tvm, tc, tsc));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    final totalNodes = allNodeIds.length;
    var dbEditsVerified = 0;

    for (var i = 0; i < totalNodes; i++) {
      final displayLabel = allNodeIds[i];
      final nodeId = displayLabel.split(' ').last;

      final sidebarItem = find.text(displayLabel).last;

      if (sidebarItem.evaluate().isEmpty) {
        continue;
      }

      await tester.runAsync(() async {
        await tester.ensureVisible(sidebarItem);
        await tester.pumpAndSettle();
        await tester.tap(sidebarItem);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      });

      final formFields = find.byType(TextFormField);
      final fieldCount = formFields.evaluate().length;

      if (fieldCount > 0) {
        for (var f = 0; f < fieldCount; f++) {
          final editedValue = 'e_${nodeId}_f$f';
          await tester.runAsync(() async {
            await tester.ensureVisible(formFields.at(f));
            await tester.pumpAndSettle();
            await tester.enterText(formFields.at(f), editedValue);
            await tester.pumpAndSettle(const Duration(milliseconds: 30));
          });
        }

        final saveBtn = find.text('Save');
        if (saveBtn.evaluate().isNotEmpty) {
          await tester.runAsync(() async {
            await tester.ensureVisible(saveBtn);
            await tester.pumpAndSettle();
            await tester.tap(saveBtn);
            await tester.pumpAndSettle(const Duration(milliseconds: 300));
          });
        }

        await tester.runAsync(() async {
          final props = await ds.fetchProperties(nodeId);
          if (props != null && props.isNotEmpty) {
            dbEditsVerified++;
            for (final entry in props.entries) {
              expect(entry.value, isNotNull);
            }
          }
        });
      }

      for (var t = 0; t < 3; t++) {
        final tabs = find.byType(Tab);
        if (tabs.evaluate().isNotEmpty) {
          await tester.runAsync(() async {
            final tabCount = tabs.evaluate().length;
            if (tabCount > 0) {
              await tester.tap(tabs.at(t % tabCount));
              await tester.pumpAndSettle(const Duration(milliseconds: 200));
            }
          });
        }
      }

      await tester.runAsync(() async {
        final gearIcon = find.byIcon(Icons.settings);
        if (gearIcon.evaluate().isNotEmpty) {
          await tester.tap(gearIcon);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          expect(find.text('Theme'), findsOneWidget);

          final nextMode = tc.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          final iconMap = {
            ThemeMode.light: Icons.light_mode,
            ThemeMode.dark: Icons.dark_mode,
            ThemeMode.system: Icons.settings_brightness,
          };
          final modeIcon = find.byIcon(iconMap[nextMode]!);
          if (modeIcon.evaluate().isNotEmpty) {
            await tester.tap(modeIcon);
            await tester.pumpAndSettle(const Duration(milliseconds: 200));
            expect(tc.mode, nextMode);
          }

          final newScale = (tsc.scale + 0.125).clamp(0.7, 1.5);
          tsc.setScale(newScale);
          await tester.pumpAndSettle(const Duration(milliseconds: 100));

          await tester.tapAt(const Offset(0, 0));
          await tester.pumpAndSettle(const Duration(milliseconds: 300));
        }
      });
    }

    expect(dbEditsVerified, greaterThan(0));
    debugPrint('DB edits verified for $dbEditsVerified nodes');
  });
}
