import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart' show SharedPreferencesThemeService;
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
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
