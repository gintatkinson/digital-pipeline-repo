import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/core/repository_provider.dart';
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

        await tester.pumpWidget(
          RepositoryProvider(
            repository: repository,
            child: MyApp(),
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();

        expect(find.byType(MyApp), findsOneWidget);
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.text('Antigravity Console'), findsAtLeast(1));
        expect(find.text('Active View: Ingestion'), findsOneWidget);
      } finally {
        await db.close();
      }
    });
  });
}
