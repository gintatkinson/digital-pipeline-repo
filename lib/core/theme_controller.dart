import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Built-in colour scheme definition for [ThemeController].
class SchemeDef {
  final Color primary;
  final Color primaryDark;
  const SchemeDef({required this.primary, required this.primaryDark});
}

/// Manages the application theme mode, colour scheme, and peristence.
///
/// Offers six built-in colour schemes plus light/dark/system mode.
/// Selections are saved via [SharedPreferences] so they survive
/// restarts. Fires [notifyListeners] on every change.
class ThemeController extends ChangeNotifier {
  static const _keyMode = 'theme_mode';
  static const _keyScheme = 'colour_scheme';

  static const _bgLight = Color(0xFFFFFFFF);
  static const _bgDark = Color(0xFF121212);
  static const _surfaceLight = Color(0xFFF1F3F4);
  static const _surfaceDark = Color(0xFF202124);

  static const schemes = <SchemeDef>[
    SchemeDef(primary: Color(0xFF1A73E8), primaryDark: Color(0xFF8AB4F8)),
    SchemeDef(primary: Color(0xFFD32F2F), primaryDark: Color(0xFFEF9A9A)),
    SchemeDef(primary: Color(0xFF43A047), primaryDark: Color(0xFFA5D6A7)),
    SchemeDef(primary: Color(0xFF7B1FA2), primaryDark: Color(0xFFCE93D8)),
    SchemeDef(primary: Color(0xFF5C5C5C), primaryDark: Color(0xFFBDBDBD)),
    SchemeDef(primary: Color(0xFFE65100), primaryDark: Color(0xFFFFCC80)),
  ];

  final SharedPreferences _prefs;
  ThemeMode _mode = ThemeMode.system;
  int _schemeIndex = 0;

  ThemeController(SharedPreferences prefs) : _prefs = prefs;

  ThemeMode get mode => _mode;
  int get schemeIndex => _schemeIndex;
  SchemeDef get currentScheme => schemes[_schemeIndex];

  ThemeData get lightTheme {
    final c = currentScheme.primary;
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: c, brightness: Brightness.light),
      scaffoldBackgroundColor: _bgLight,
      cardColor: _surfaceLight,
      dividerColor: const Color(0xFFE0E0E0),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        isDense: true,
        filled: true,
        fillColor: _bgLight,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  ThemeData get darkTheme {
    final c = currentScheme.primaryDark;
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: c, brightness: Brightness.dark),
      scaffoldBackgroundColor: _bgDark,
      cardColor: _surfaceDark,
      dividerColor: const Color(0xFF424242),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        isDense: true,
        filled: true,
        fillColor: _surfaceDark,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  void loadSettings() {
    final modeRaw = _prefs.getString(_keyMode);
    if (modeRaw != null) {
      _mode = _parseMode(modeRaw);
    }
    final schemeRaw = _prefs.getInt(_keyScheme);
    if (schemeRaw != null && schemeRaw >= 0 && schemeRaw < schemes.length) {
      _schemeIndex = schemeRaw;
    }
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    await _prefs.setString(_keyMode, value.name);
    notifyListeners();
  }

  Future<void> updateScheme(int index) async {
    if (index < 0 || index >= schemes.length || index == _schemeIndex) return;
    _schemeIndex = index;
    await _prefs.setInt(_keyScheme, index);
    notifyListeners();
  }

  static ThemeMode _parseMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }
}
