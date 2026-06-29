import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart' show SharedPreferencesThemeService;
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> _createInMemoryDb({bool seed = true}) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return DatabaseInitializer.create(
    dbPath: inMemoryDatabasePath,
    seed: seed,
  );
}

void main() {
  test('Seed populates type_definitions table', () async {
    final db = await _createInMemoryDb(seed: true);
    try {
      final rows = await db.query('type_definitions');
      expect(rows.length, greaterThan(0));

      final attrRows = await db.query('type_attributes');
      expect(attrRows.length, greaterThan(0));

      final relRows = await db.query('type_relations');
      expect(relRows.length, greaterThan(0));

      // Verify concrete entries
      final location = rows.firstWhere((r) => r['type_name'] == 'Location');
      expect(location['display_name'], 'Location');

      final lat = attrRows.firstWhere((r) => r['attr_key'] == 'latitude');
      expect(lat['default_value'], '37.7749');
      expect(lat['section_label'], 'Geodetic Coordinate Frame');

      final locType = attrRows.firstWhere((r) => r['attr_key'] == 'locationType');
      final enumOpts = jsonDecode(locType['enum_options'] as String) as List;
      expect(enumOpts, contains('site'));

      final ingRel = relRows.firstWhere(
        (r) => r['parent_type_name'] == 'Monitoring' && r['child_type_name'] == 'Location',
      );
      expect(ingRel['relation_name'], 'contains');
    } finally {
      await db.close();
    }
  });

  testWidgets('Dashboard console boots and renders main widgets successfully',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await DatabaseInitializer.create(
        dbPath: inMemoryDatabasePath,
        seed: false,
      );
      try {
        final repository = SqliteRepositoryAdapter(db);
        final themeController = ThemeController(SharedPreferencesThemeService());

        final textScaler = TextScalerController();
        await textScaler.load();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AbstractRepository>.value(value: repository),
              ChangeNotifierProvider<ThemeController>.value(value: themeController),
              ChangeNotifierProvider<TextScalerController>.value(value: textScaler),
            ],
            child: MyApp(),
          ),
        );

        await tester.pump();

        expect(find.byType(MyApp), findsOneWidget);
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.text('Antigravity Console'), findsAtLeast(1));
      } finally {
        await db.close();
      }
    });
  });
}
