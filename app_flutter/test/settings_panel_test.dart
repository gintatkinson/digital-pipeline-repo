import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipeline_app/core/theme_controller.dart';
import 'package:pipeline_app/core/text_scaler.dart';
import 'package:pipeline_app/features/settings/settings_panel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders theme mode buttons and text slider', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final tc = ThemeController(prefs);
    final tsc = TextScaleController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsPanel(themeController: tc, textScaleController: tsc),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Colour'), findsOneWidget);
    expect(find.text('Text Size'), findsOneWidget);
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('renders colour swatches', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final tc = ThemeController(prefs);
    final tsc = TextScaleController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SettingsPanel(themeController: tc, textScaleController: tsc),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
