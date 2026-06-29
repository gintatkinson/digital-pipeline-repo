import 'dart:convert';
import 'dart:io';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/main.dart' as app_main;
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/core/theme/widgets/settings_panel.dart';
import 'package:app_flutter/features/tree/tree_defaults.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

final File benchmarkLogFile = File(
  '/Users/perkunas/opcode/digital-pipeline-repo/benchmark_results.jsonl',
);

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

Future<void> _changeSettingsViaUI(
    WidgetTester tester, ThemeMode themeMode, double textScale) async {
  await tester.ensureVisible(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.settings));
  await tester.pumpAndSettle();

  final IconData themeIcon;
  switch (themeMode) {
    case ThemeMode.light:
      themeIcon = Icons.light_mode;
    case ThemeMode.dark:
      themeIcon = Icons.dark_mode;
    case ThemeMode.system:
      themeIcon = Icons.settings_brightness;
  }
  await tester.tap(find.byIcon(themeIcon).last);
  await tester.pumpAndSettle();

  final slider = find.descendant(
    of: find.byType(SettingsPanel),
    matching: find.byType(Slider),
  );
  final rect = tester.getRect(slider);
  const double min = 0.7;
  const double max = 1.5;
  final double fraction = (textScale - min) / (max - min);
  final double targetX = rect.left + fraction * rect.width;
  await tester.timedDrag(
    slider,
    Offset(targetX - rect.center.dx, 0),
    const Duration(milliseconds: 200),
  );
  await tester.pumpAndSettle();

  await tester.tapAt(Offset.zero);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Stress test: cycle theme + text size between each full 20-node pass',
      (tester) async {
    tester.binding.setSurfaceSize(const Size(2000, 4000));

    await app_main.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    int attempts = 0;
    while (attempts < 20 && find.byKey(const Key('node_Ingestion')).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }

    final themeCtrl = app_main.globalThemeController;
    final textCtrl = app_main.globalTextScalerController;
    if (themeCtrl == null || textCtrl == null) {
      fail('Benchmark: controllers not initialized by main()');
    }

    final List<ThemeMode> themeModes = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
    ];

    final List<int> memorySamples = [];
    int passCount = 0;

    while (passCount < 10) {
      // Current settings for this pass
      final ThemeMode themeMode = themeModes[passCount % themeModes.length];
      final double textScale = 0.7 + (passCount % 9) * 0.1;

      // Apply settings via UI so the user sees the changes
      await _changeSettingsViaUI(tester, themeMode, textScale);

      // Run 20-node pass with current settings
      final memBefore = ProcessInfo.currentRss;
      final stopwatch = Stopwatch()..start();

      String? crashNodeId;
      String? crashAction;

      try {
        for (int nodeIdx = 0; nodeIdx < allNodeIds.length; nodeIdx++) {
          final String nodeId = allNodeIds[nodeIdx];

          crashNodeId = nodeId;
          crashAction = 'tap';
          await tester.ensureVisible(find.byKey(Key('node_$nodeId')));
          await tester.tap(find.byKey(Key('node_$nodeId')));
          await tester.pump();
          await tester.pump();

          crashAction = 'edit_fields';
          await _editTextFields(tester, [
            ('Latitude', ((nodeIdx + 1) * (passCount + 1) * 1.5).toString()),
            ('Longitude', (-(nodeIdx + 1) * (passCount + 1) * 2.0).toString()),
            ('Elevation / Altitude (m)', ((nodeIdx + 1) * (passCount + 1) * 3).toString()),
            ('Room Identifier', 'Room-$nodeIdx-$passCount'),
            ('Grid Row', ((nodeIdx + 1) * (passCount + 1) * 2 % 100).toString()),
            ('Grid Column', ((nodeIdx + 1) * (passCount + 1) % 50).toString()),
            ('Max Voltage (V)', ((nodeIdx + 1) * (passCount + 1) * 10.0).toString()),
            ('Max Allocated Power (W)', ((nodeIdx + 1) * (passCount + 1) * 100.0).toString()),
            ('Country Code (ISO-2)', _FieldHelper.countryCode(nodeIdx, passCount)),
          ]);

          crashAction = 'dropdown_tap';
          await tester.tap(_FieldHelper.dropdownByLabel('Location Hierarchy Type'));
          await tester.pump();
          await tester.pump();
          crashAction = 'dropdown_select';
          await tester.tap(find.text(_FieldHelper.locationTypeDisplayName(nodeIdx, passCount)).last);
          await tester.pump();
          await tester.pump();
        }
      } catch (e, st) {
        print('BENCHMARK_CRASH: ${jsonEncode({
          "pass": passCount,
          "theme": themeMode.toString(),
          "text_scale": textScale,
          "last_node": crashNodeId,
          "last_action": crashAction,
          "error": e.toString(),
          "stack": st.toString().substring(0, 500),
        })}');
        rethrow;
      }

      stopwatch.stop();
      final memAfter = ProcessInfo.currentRss;
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final avgMsPerNode = elapsedMs / allNodeIds.length;
      final memDeltaKb = (memAfter - memBefore) ~/ 1024;

      memorySamples.add(memAfter);
      if (memorySamples.length >= 5) {
        final recent = memorySamples.sublist(memorySamples.length - 5);
        final netGrowth = recent.last - recent.first;
        if (netGrowth > 20 * 1024 * 1024) {
          print('BENCHMARK_LEAK: ${jsonEncode({
            "message": "Memory grew >20MB over 5 consecutive passes",
            "samples": recent,
            "pass": passCount,
            "net_growth_bytes": netGrowth,
          })}');
        }
      }

      // Verify last node was reached
      final lastNodeId = allNodeIds.last;
      expect(find.byKey(Key('node_$lastNodeId')), findsOneWidget,
          reason: 'Last node $lastNodeId should exist after pass $passCount');

      // Verify settings were applied
      expect(themeCtrl.themeMode, equals(themeMode),
          reason: 'Theme should be $themeMode after pass $passCount');
      expect(textCtrl.scale, closeTo(textScale, 0.01),
          reason: 'Text scale should be $textScale after pass $passCount');

      final String themeName;
      switch (themeMode) {
        case ThemeMode.light: themeName = 'light'; break;
        case ThemeMode.dark: themeName = 'dark'; break;
        case ThemeMode.system: themeName = 'system'; break;
      }

      final results = {
        'total_time_ms': elapsedMs,
        'avg_time_per_node_ms': avgMsPerNode.toStringAsFixed(1),
        'theme_mode': themeName,
        'text_scale': textScale,
        'pass_count': passCount,
        'memory_delta_kb': memDeltaKb,
        'passed': true,
      };

      print('STRESS_RESULT: ${jsonEncode(results)}');

      final logFile = benchmarkLogFile;
      await logFile.writeAsString(
        '${jsonEncode({...results, "timestamp": DateTime.now().toIso8601String()})}\n',
        mode: FileMode.append,
      );

      passCount++;

      // Drain pending async saves
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  });
}
