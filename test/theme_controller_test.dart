import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipeline_app/core/theme_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system theme mode', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    expect(controller.mode, ThemeMode.system);
    expect(controller.schemeIndex, 0);
  });

  test('lightTheme returns Material ThemeData', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    final theme = controller.lightTheme;
    expect(theme, isA<ThemeData>());
    expect(theme.brightness, Brightness.light);
  });

  test('darkTheme returns Material ThemeData', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    final theme = controller.darkTheme;
    expect(theme, isA<ThemeData>());
    expect(theme.brightness, Brightness.dark);
  });

  test('updateThemeMode persists and notifies', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);

    var notified = false;
    controller.addListener(() => notified = true);

    await controller.updateThemeMode(ThemeMode.dark);
    expect(controller.mode, ThemeMode.dark);
    expect(notified, true);

    final newPrefs = await SharedPreferences.getInstance();
    expect(newPrefs.getString('theme_mode'), 'dark');
  });

  test('loadSettings restores persisted mode', () async {
    await SharedPreferences.getInstance().then((p) => p.setString('theme_mode', 'light'));

    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    controller.loadSettings();
    expect(controller.mode, ThemeMode.light);
  });

  test('updateScheme cycles and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);

    await controller.updateScheme(2);
    expect(controller.schemeIndex, 2);

    final newPrefs = await SharedPreferences.getInstance();
    expect(newPrefs.getInt('colour_scheme'), 2);
  });

  test('no-op on same theme mode', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);

    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.updateThemeMode(ThemeMode.system);
    expect(notifications, 0);
  });
}
