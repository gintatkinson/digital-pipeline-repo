import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/main.dart' as app_main;
import 'package:app_flutter/config/tree_defaults.dart';
import 'package:app_flutter/components/tree_node.dart';

const Duration _kFrame = Duration.zero;

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

String _nodeLabel(String nodeId) {
  String? find(List<TreeNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node.label;
      if (node.children != null) {
        final result = find(node.children!, id);
        if (result != null) return result;
      }
    }
    return null;
  }
  return find(defaultTreeData, nodeId) ?? nodeId;
}

final List<String> allNodeIds = _flattenNodes(defaultTreeData);

Future<void> _editTextField(
    WidgetTester tester, String label, String value) async {
  await tester.enterText(_FieldHelper.textFieldByLabel(label), value);
  await tester.pump(_kFrame);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(_kFrame);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration: 10 cycles x 20 nodes x all PropertyGrid fields',
      (tester) async {
    await app_main.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    int attempts = 0;
    while (attempts < 20 && find.byKey(const Key('node_Ingestion')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }
    print('[TEST] Nodes found after wait: ${find.byKey(const Key('node_Ingestion')).evaluate().length}');

    for (int cycle = 0; cycle < 10; cycle++) {
      for (int nodeIdx = 0; nodeIdx < allNodeIds.length; nodeIdx++) {
        final String nodeId = allNodeIds[nodeIdx];
        final String nodeLabel = _nodeLabel(nodeId);
        print(
            '[TEST] Node ${nodeIdx + 1}/${allNodeIds.length}: $nodeLabel');

        await tester.ensureVisible(find.byKey(Key('node_$nodeId')));
        await tester.pump(_kFrame);
        await tester.tap(find.byKey(Key('node_$nodeId')));
        await tester.pump(_kFrame);

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

        await tester.ensureVisible(
            _FieldHelper.dropdownByLabel('Location Hierarchy Type'));
        await tester.pump(_kFrame);
        await tester.tap(
            _FieldHelper.dropdownByLabel('Location Hierarchy Type'));
        await tester.pump(_kFrame);
        final dropdownItem = find.text(
            _FieldHelper.locationTypeDisplayName(nodeIdx, cycle)).last;
        await tester.ensureVisible(dropdownItem);
        await tester.pump(_kFrame);
        await tester.tap(dropdownItem);
        await tester.pump(_kFrame);
      }
    }
  });
}
