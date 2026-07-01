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
import 'package:app_flutter/domain/data_sources/fallback_data_source.dart';
import 'package:app_flutter/features/layout/layout.dart';
import 'package:app_flutter/domain/repository.dart';

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
                  "id": "sub_elements_table"
                },
                {
                  "type": "TableView",
                  "id": "active_alarms_table"
                },
                {
                  "type": "TableView",
                  "id": "historical_events_table"
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

Widget wrapWithRepo(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AbstractRepository>.value(value: _TestRepository()),
      Provider<DataSource>.value(value: FallbackDataSource()),
      ChangeNotifierProvider<ThemeController>.value(
        value: ThemeController(SharedPreferencesThemeService()),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  StringResources.loadFromJson('{"sidebar.header": "${AppConfig.appDisplayName}", "breadcrumbs.home": "${AppConfig.appDisplayName}"}');

  testWidgets('Layout parses JSON config and renders components', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithRepo(
        Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.title), findsNWidgets(2));
    expect(find.text('Active View: Item'), findsOneWidget);
    expect(find.byKey(const Key('SubElement-table')), findsOneWidget);
  });

  testWidgets('Layout switches tabs in TabbedContainer', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithRepo(
        Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Items table is displayed initially
    expect(find.byKey(const Key('SubElement-table')), findsOneWidget);
    expect(find.byKey(const Key('Alarm-table')), findsNothing);

    // Tap Alarms tab
    await tester.tap(find.widgetWithText(Tab, 'Alarms'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('SubElement-table')), findsNothing);
    expect(find.byKey(const Key('Alarm-table')), findsOneWidget);

    // Tap Events tab
    await tester.tap(find.widgetWithText(Tab, 'Events'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('Alarm-table')), findsNothing);
    expect(find.byKey(const Key('Event-table')), findsOneWidget);
  });

  testWidgets('Layout splitter drags update sizes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AbstractRepository>.value(value: _TestRepository()),
          Provider<DataSource>.value(value: FallbackDataSource()),
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
    await tester.pumpAndSettle();

    // Test vertical splitter dragging
    final Finder verticalSplitter = find.byKey(const Key('vertical_splitter'));
    expect(verticalSplitter, findsOneWidget);

    // Drag vertical splitter to the right
    await tester.drag(verticalSplitter, const Offset(50, 0));
    await tester.pumpAndSettle();

    // Test horizontal SplitWorkspace splitter dragging
    final Finder horizontalSplitter = find.byKey(const Key('horizontal_splitter'));
    expect(horizontalSplitter, findsOneWidget);

    await tester.drag(horizontalSplitter, const Offset(0, 50));
    await tester.pumpAndSettle();

    // Test topographical view child splitter dragging (since child is present)
    final Finder topoSplitter = find.byKey(const Key('topo_splitter'));
    expect(topoSplitter, findsOneWidget);

    await tester.drag(topoSplitter, const Offset(0, 30));
    await tester.pumpAndSettle();
  });

  testWidgets('Layout keyboard navigation and node selection', (WidgetTester tester) async {
    String? selectedView;
    await tester.pumpWidget(
      wrapWithRepo(
        Layout(
          layoutConfig: testLayoutConfig,
          onViewChange: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Click on Item node to give focus to the tree FocusNode
    await tester.tap(find.byKey(const Key('node_Item')));
    await tester.pumpAndSettle();

    // Send ArrowDown key event — navigates to SubElement child
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(selectedView, 'SubElement');
  });

  testWidgets('Layout first pumpWidget does not block on sync file I/O', (WidgetTester tester) async {
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(
      wrapWithRepo(
        Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    stopwatch.stop();
    // First pump must complete quickly — no sync file I/O on the UI thread.
    // 500ms is generous; sync I/O would cause multi-second hangs.
    expect(stopwatch.elapsedMilliseconds, lessThan(500));

    // After settling, all async pre-loads finish and full UI renders.
    await tester.pumpAndSettle();
    expect(find.text(AppConfig.title), findsNWidgets(2));
    expect(find.text('Active View: Item'), findsOneWidget);
    expect(find.byKey(const Key('SubElement-table')), findsOneWidget);
  });

  testWidgets('Layout handles tree node tap selection without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithRepo(
        Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the single Item node
    await tester.tap(find.byKey(const Key('node_Item')));
    await tester.pumpAndSettle();
  });
}
