import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/components/property_grid.dart';
import 'package:app_flutter/components/sidebar_tree.dart';
import 'package:app_flutter/config/tree_defaults.dart';
import 'package:app_flutter/components/tree_node.dart';

class _FieldHelper {
  static Finder textFieldByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is Column) {
        final List<Widget> children = widget.children;
        if (children.isNotEmpty && children.first is Text) {
          return (children.first as Text).data == labelText;
        }
      }
      return false;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(TextField),
    );
  }

  static Finder dropdownByLabel(String labelText) {
    final Finder columnFinder = find.byWidgetPredicate((Widget widget) {
      if (widget is Column) {
        final List<Widget> children = widget.children;
        if (children.isNotEmpty && children.first is Text) {
          return (children.first as Text).data == labelText;
        }
      }
      return false;
    });
    return find.descendant(
      of: columnFinder,
      matching: find.byType(DropdownButtonFormField<String>),
    );
  }

  static String countryCode(int nodeIndex, int cycle) {
    final int c1 = 65 + ((nodeIndex + cycle) % 26);
    final int c2 = 65 + ((nodeIndex * 3 + cycle * 7) % 26);
    return String.fromCharCodes([c1, c2]);
  }

  static String locationTypeDisplayName(int nodeIndex, int cycle) {
    const List<String> options = ['site', 'room', 'building'];
    final String value = options[(nodeIndex + cycle) % options.length];
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

List<String> _flattenNodes(List<TreeNode> nodes) {
  final List<String> result = [];
  for (final node in nodes) {
    result.add(node.id);
    if (node.children != null) {
      result.addAll(_flattenNodes(node.children!));
    }
  }
  return result;
}

final List<String> allNodeIds = _flattenNodes(defaultTreeData);

class _IterationHarness extends StatefulWidget {
  const _IterationHarness();

  @override
  State<_IterationHarness> createState() => _IterationHarnessState();
}

class _IterationHarnessState extends State<_IterationHarness> {
  String _currentView = 'Ingestion';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 280,
              child: SidebarTree(
                treeData: defaultTreeData,
                currentView: _currentView,
                themeMode: 'light',
                onViewSelected: (view) {
                  setState(() => _currentView = view);
                },
              ),
            ),
            Expanded(
              child: PropertyGrid(
                key: ValueKey(_currentView),
                activeView: _currentView,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodeIterationHelper {
  static Future<void> run(WidgetTester tester) async {
    await tester.pumpWidget(const _IterationHarness());
    await tester.pumpAndSettle();

    for (int cycle = 0; cycle < 10; cycle++) {
      for (int nodeIdx = 0; nodeIdx < allNodeIds.length; nodeIdx++) {
        final String nodeId = allNodeIds[nodeIdx];
        await tester.tap(find.byKey(Key('node_$nodeId')));
        await tester.pumpAndSettle();

        expect(find.byType(PropertyGrid), findsOneWidget);

        await _editTextField(tester, 'Latitude',
            ((nodeIdx + 1) * (cycle + 1) * 1.5).toString());
        await _editTextField(tester, 'Longitude',
            (-(nodeIdx + 1) * (cycle + 1) * 2.0).toString());
        await _editTextField(tester, 'Elevation / Altitude (m)',
            ((nodeIdx + 1) * (cycle + 1) * 3).toString());
        await _editTextField(tester, 'Room Identifier',
            'Room-$nodeIdx-$cycle');
        await _editTextField(tester, 'Grid Row',
            ((nodeIdx + 1) * (cycle + 1) * 2 % 100).toString());
        await _editTextField(tester, 'Grid Column',
            ((nodeIdx + 1) * (cycle + 1) % 50).toString());
        await _editTextField(tester, 'Max Voltage (V)',
            ((nodeIdx + 1) * (cycle + 1) * 10.0).toString());
        await _editTextField(tester, 'Max Allocated Power (W)',
            ((nodeIdx + 1) * (cycle + 1) * 100.0).toString());
        await _editTextField(tester, 'Country Code (ISO-2)',
            _FieldHelper.countryCode(nodeIdx, cycle));

        await tester.tap(_FieldHelper.dropdownByLabel('Location Hierarchy Type'));
        await tester.pumpAndSettle();
        await tester.tap(
            find.text(_FieldHelper.locationTypeDisplayName(nodeIdx, cycle)).last);
        await tester.pumpAndSettle();
      }
    }
  }

  static Future<void> _editTextField(
      WidgetTester tester, String label, String value) async {
    await tester.enterText(_FieldHelper.textFieldByLabel(label), value);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
    'Harness: 10 cycles x 20 nodes x all PropertyGrid fields',
    NodeIterationHelper.run,
  );
}
