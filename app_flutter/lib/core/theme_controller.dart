import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  static const _primaryColor = Color(0xFF1A73E8);

  static const _lightBackground = Color(0xFFFFFFFF);
  static const _lightSurface = Color(0xFFF1F3F4);
  static const _darkBackground = Color(0xFF121212);
  static const _darkSurface = Color(0xFF202124);

  final SharedPreferences _prefs;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  ThemeController(SharedPreferences prefs)
      : _prefs = prefs,
        _mode = ThemeMode.system;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: _lightBackground,
        cardColor: _lightSurface,
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _darkBackground,
        cardColor: _darkSurface,
      );

  void loadSettings() {
    final saved = _prefs.getString(_prefsKey);
    if (saved == null) return;

    _mode = _modeFromString(saved);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    await _prefs.setString(_prefsKey, value.name);
    notifyListeners();
  }

  static ThemeMode _modeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
