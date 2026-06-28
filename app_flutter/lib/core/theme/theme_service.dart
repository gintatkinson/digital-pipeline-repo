import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeService {
  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode themeMode);
  Future<int> loadThemeScheme();
  Future<void> saveThemeScheme(int index);
  Future<double> loadTextScale();
  Future<void> saveTextScale(double scale);
}

class SharedPreferencesThemeService implements ThemeService {
  static const _modeKey = 'theme_mode';
  static const _schemeKey = 'theme_scheme';

  @override
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_modeKey);
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = themeMode == ThemeMode.light ? 'light'
        : themeMode == ThemeMode.dark ? 'dark'
        : 'system';
    await prefs.setString(_modeKey, value);
  }

  @override
  Future<int> loadThemeScheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_schemeKey) ?? 0;
  }

  @override
  Future<void> saveThemeScheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_schemeKey, index);
  }

  static const _textScaleKey = 'text_scale';

  @override
  Future<double> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textScaleKey) ?? 1.0;
  }

  @override
  Future<void> saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }
}
