import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/components/layout.dart';

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

void main() {
  testWidgets('Layout parses JSON config and renders components', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antigravity Console'), findsNWidgets(2));
    expect(find.text('Active View: Ingestion'), findsOneWidget);
    expect(find.byKey(const Key('items-table')), findsOneWidget);
  });

  testWidgets('Layout switches tabs in TabbedContainer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Layout(
          layoutConfig: testLayoutConfig,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Items table is displayed initially
    expect(find.byKey(const Key('items-table')), findsOneWidget);
    expect(find.byKey(const Key('status-table')), findsNothing);

    // Tap Status tab
    await tester.tap(find.byKey(const Key('tab_btn_active_alarms_table')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('items-table')), findsNothing);
    expect(find.byKey(const Key('status-table')), findsOneWidget);

    // Tap Activity tab
    await tester.tap(find.byKey(const Key('tab_btn_historical_events_table')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('status-table')), findsNothing);
    expect(find.byKey(const Key('activity-table')), findsOneWidget);
  });

  testWidgets('Layout splitter drags update sizes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Layout(
            layoutConfig: testLayoutConfig,
            child: Container(key: const Key('property_grid_stub'), height: 100),
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
      MaterialApp(
        home: Layout(
          layoutConfig: testLayoutConfig,
          onViewChange: (view) => selectedView = view,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Click on Ingestion node to give focus to the tree FocusNode
    await tester.tap(find.byKey(const Key('node_Ingestion')));
    await tester.pumpAndSettle();

    // Send ArrowDown key event
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    // Ingestion -> Monitoring is the next visible node
    expect(selectedView, 'Monitoring');

    // Reset selectedView and send ArrowDown again
    selectedView = null;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    // Monitoring -> Metrics (since Monitoring is expanded by default)
    expect(selectedView, 'Metrics');

    // Send ArrowLeft (goes to parent of Metrics, which is Monitoring)
    selectedView = null;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(selectedView, 'Monitoring');

    // Send ArrowLeft on Monitoring (which is expanded parent) -> collapses it
    selectedView = null;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    // Monitoring should be collapsed now, so sending ArrowDown goes to Spec (skipping Metrics, Location, Chassis)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(selectedView, 'Spec');
  });
}
