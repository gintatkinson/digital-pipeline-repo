import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/main.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  testWidgets('Dashboard console boots and renders main widgets successfully', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      try {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS properties (node_id TEXT PRIMARY KEY, data_json TEXT NOT NULL);',
        );
        final repository = SqliteRepositoryAdapter(db);

        // Build our app and trigger a frame.
        await tester.pumpWidget(MyApp(repository: repository));

        // Allow FutureBuilder and SQLite Stream to resolve
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        // Verify that the console boots successfully and there are no crash loops
        expect(find.byType(MyApp), findsOneWidget);
        expect(find.byType(DashboardPage), findsOneWidget);

        // Verify the 'Antigravity Console' header exists (it's present in the tree navigation area)
        expect(find.text('Antigravity Console'), findsAtLeast(1));

        // Verify the active view text exists and starts at 'Ingestion'
        expect(find.text('Active View: Ingestion'), findsOneWidget);
      } finally {
        await db.close();
      }
    });
  });
}
