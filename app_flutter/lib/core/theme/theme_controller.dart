import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'app_themes.dart';
import 'theme_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._themeService);
  final ThemeService _themeService;
  ThemeMode _themeMode = ThemeMode.system;
  int _currentThemeIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get currentThemeIndex => _currentThemeIndex;
  FlexSchemeData get currentTheme => AppThemes.customSchemes[_currentThemeIndex];

  Future<void> loadSettings() async {
    _themeMode = await _themeService.loadThemeMode();
    _currentThemeIndex = await _themeService.loadThemeScheme();
    if (_currentThemeIndex < 0 || _currentThemeIndex >= AppThemes.customSchemes.length) {
      _currentThemeIndex = 0;
    }
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _themeService.saveThemeMode(newThemeMode);
  }

  Future<void> updateThemeScheme(int? newIndex) async {
    if (newIndex == null || newIndex == _currentThemeIndex) return;
    if (newIndex < 0 || newIndex >= AppThemes.customSchemes.length) return;
    _currentThemeIndex = newIndex;
    notifyListeners();
    await _themeService.saveThemeScheme(newIndex);
  }
}
