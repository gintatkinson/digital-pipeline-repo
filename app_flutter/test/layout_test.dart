import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/core/app_config.dart';
import 'package:app_flutter/core/string_resources.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart' show SharedPreferencesThemeService;
import 'package:app_flutter/domain/data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/database_initializer.dart';
import 'package:app_flutter/domain/data_sources/sqlite_data_source.dart';
import 'package:app_flutter/features/layout/layout.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/features/tables/tabbed_container.dart';
import 'package:app_flutter/features/tables/view_models/tables_view_model.dart';

class _TestRepository implements AbstractRepository {
  @override
  Future<Map<String, dynamic>> fetchProperties(String nodeId) async => {};
  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) async {}
  @override
  Stream<Map<String, dynamic>> watchProperties(String nodeId) => Stream.empty();
  @override
  Future<List<Map<String, dynamic>>> fetchElements(String parentNodeId) async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchAlarms(String parentNodeId) async => [];
  @override
  Future<List<Map<String, dynamic>>> fetchEvents(String parentNodeId) async => [];
}

const String testLayoutConfig = '''
{
  "layout": {
    "root_container": {
      "type": "SidebarLayout",
      "id": "main_shell",
      "children": [
        {
          "type": "HierarchyTreeSelector",
          "id": "resource_tree"
        },
        {
          "type": "SplitWorkspace",
          "id": "workspace_split",
          "children": [
            {
              "type": "TopographicalView",
              "id": "topology_pane"
            },
            {
              "type": "TabbedContainer",
              "id": "details_and_relations_tab",
              "children": [
                {
                  "type": "TableView",
                  "id": "components_table"
                },
                {
                  "type": "TableView",
                  "id": "relation_a_table"
                },
                {
                  "type": "TableView",
                  "id": "relation_b_table"
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
''';

Future<Database> createTestDatabase() async {
  return DatabaseInitializer.create(
    dbPath: inMemoryDatabasePath,
    seed: true,
  );
}

Widget wrapWithRepo(Widget child, DataSource dataSource) {
  return MultiProvider(
    providers: [
      Provider<AbstractRepository>.value(value: _TestRepository()),
      Provider<DataSource>.value(value: dataSource),
      ChangeNotifierProvider<ThemeController>.value(
        value: ThemeController(SharedPreferencesThemeService()),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Future<void> settle(WidgetTester tester) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await tester.pump();

  for (int i = 0; i < 50; i++) {
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await tester.pump();
  }

  for (int i = 0; i < 3; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await tester.pump();
  }
}

void main() {
  StringResources.loadFromJson('{"sidebar.header": "Platform Console", "breadcrumbs.home": "Platform Console"}');

  testWidgets('Layout parses JSON config and renders components', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      final db = await createTestDatabase();
      addTearDown(() => db.close());

      await tester.pumpWidget(
        wrapWithRepo(
          Layout(
            activeView: 'root',
            layoutConfig: testLayoutConfig,
          ),
          SqliteDataSource(db),
        ),
      );
      await settle(tester);

      expect(find.text(AppConfig.title), findsNWidgets(2));
      expect(find.text('Active View: root'), findsOneWidget);
      expect(find.byKey(const Key('Component-table')), findsNothing);

      await tester.pumpWidget(Container());
      await settle(tester);
    });
  });

  testWidgets('Layout switches tabs in TabbedContainer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      final db = await createTestDatabase();
      addTearDown(() => db.close());

      await tester.pumpWidget(
        wrapWithRepo(
          Layout(
            activeView: 'Item',
            layoutConfig: testLayoutConfig,
          ),
          SqliteDataSource(db),
        ),
      );
      await settle(tester);

      // Components table is displayed initially
      expect(find.byKey(const Key('Component-table')), findsOneWidget);
      expect(find.byKey(const Key('RelationA-table')), findsNothing);

      // Tap Relation A tab
      await tester.tap(find.widgetWithText(Tab, 'Relation A'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await settle(tester);

      expect(find.byKey(const Key('Component-table')), findsNothing);
      expect(find.byKey(const Key('RelationA-table')), findsOneWidget);

      // Tap Relation B tab
      await tester.tap(find.widgetWithText(Tab, 'Relation B'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await settle(tester);

      expect(find.byKey(const Key('RelationA-table')), findsNothing);
      expect(find.byKey(const Key('RelationB-table')), findsOneWidget);

      await tester.pumpWidget(Container());
      await settle(tester);
    });
  });

  testWidgets('Layout splitter drags update sizes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      final db = await createTestDatabase();
      addTearDown(() => db.close());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AbstractRepository>.value(value: _TestRepository()),
            Provider<DataSource>.value(value: SqliteDataSource(db)),
            ChangeNotifierProvider<ThemeController>.value(
              value: ThemeController(SharedPreferencesThemeService()),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Layout(
                layoutConfig: testLayoutConfig,
              ),
            ),
          ),
        ),
      );
      await settle(tester);

      // Test vertical splitter dragging
      final Finder verticalSplitter = find.byKey(const Key('vertical_splitter'));
      expect(verticalSplitter, findsOneWidget);

      // Drag vertical splitter to the right
      await tester.drag(verticalSplitter, const Offset(50, 0));
      await settle(tester);

      // Test horizontal SplitWorkspace splitter dragging
      final Finder horizontalSplitter = find.byKey(const Key('horizontal_splitter'));
      expect(horizontalSplitter, findsOneWidget);

      await tester.drag(horizontalSplitter, const Offset(0, 50));
      await settle(tester);

      // Test topographical view child splitter dragging (since child is present)
      final Finder topoSplitter = find.byKey(const Key('topo_splitter'));
      expect(topoSplitter, findsOneWidget);

      await tester.drag(topoSplitter, const Offset(0, 30));
      await settle(tester);

      await tester.pumpWidget(Container());
      await settle(tester);
    });
  });

  testWidgets('Layout keyboard navigation and node selection', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      final db = await createTestDatabase();
      addTearDown(() => db.close());

      String? selectedView;
      await tester.pumpWidget(
        wrapWithRepo(
          Layout(
            layoutConfig: testLayoutConfig,
            onViewChange: (view) => selectedView = view,
          ),
          SqliteDataSource(db),
        ),
      );
      await settle(tester);

      // Click on Item node to give focus to the tree FocusNode
      await tester.tap(find.byKey(const Key('node_Item')));
      await settle(tester);

      // Send ArrowDown key event — navigates to Component child
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(selectedView, 'Component');

      await tester.pumpWidget(Container());
      await settle(tester);
    });
  });

  testWidgets('Layout handles tree node tap selection without crashing', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      final db = await createTestDatabase();
      addTearDown(() => db.close());

      await tester.pumpWidget(
        wrapWithRepo(
          Layout(
            layoutConfig: testLayoutConfig,
          ),
          SqliteDataSource(db),
        ),
      );
      await settle(tester);

      // Tap the single Item node
      await tester.tap(find.byKey(const Key('node_Item')));
      await settle(tester);

      await tester.pumpWidget(Container());
      await settle(tester);
    });
  });
}
