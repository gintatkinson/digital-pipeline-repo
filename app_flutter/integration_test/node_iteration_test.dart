import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/main.dart' as app_main;
import 'package:app_flutter/features/tree/tree_defaults.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

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

Future<void> _editTextFields(
    WidgetTester tester, List<(String, String)> fields) async {
  for (final (label, value) in fields) {
    await tester.enterText(_FieldHelper.textFieldByLabel(label), value);
  }
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration: 10 cycles x 20 nodes x all PropertyGrid fields',
      (tester) async {
    tester.binding.setSurfaceSize(const Size(2000, 3000));

    await app_main.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    int attempts = 0;
    while (attempts < 20 && find.byKey(const Key('node_Ingestion')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }

    for (int cycle = 0; cycle < 10; cycle++) {
      for (int nodeIdx = 0; nodeIdx < allNodeIds.length; nodeIdx++) {
        final String nodeId = allNodeIds[nodeIdx];

        await tester.tap(find.byKey(Key('node_$nodeId')));
        await tester.pump();
        await tester.pump();

        await _editTextFields(tester, [
          ('Latitude', ((nodeIdx + 1) * (cycle + 1) * 1.5).toString()),
          ('Longitude', (-(nodeIdx + 1) * (cycle + 1) * 2.0).toString()),
          ('Elevation / Altitude (m)', ((nodeIdx + 1) * (cycle + 1) * 3).toString()),
          ('Room Identifier', 'Room-$nodeIdx-$cycle'),
          ('Grid Row', ((nodeIdx + 1) * (cycle + 1) * 2 % 100).toString()),
          ('Grid Column', ((nodeIdx + 1) * (cycle + 1) % 50).toString()),
          ('Max Voltage (V)', ((nodeIdx + 1) * (cycle + 1) * 10.0).toString()),
          ('Max Allocated Power (W)', ((nodeIdx + 1) * (cycle + 1) * 100.0).toString()),
          ('Country Code (ISO-2)', _FieldHelper.countryCode(nodeIdx, cycle)),
        ]);

        await tester.tap(
            _FieldHelper.dropdownByLabel('Location Hierarchy Type'));
        await tester.pump();
        await tester.pump();
        await tester.tap(
            find.text(_FieldHelper.locationTypeDisplayName(nodeIdx, cycle)).last);
        await tester.pump();
        await tester.pump();
      }
    }
  });
}
