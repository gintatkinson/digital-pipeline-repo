import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'app_themes.dart';
import 'theme_service.dart';

/// Manages theme mode, color scheme selection, and persistence
/// via [ThemeService]. Notifies listeners on changes.
class ThemeController extends ChangeNotifier {
  ThemeController(this._themeService);
  final ThemeService _themeService;
  ThemeMode _themeMode = ThemeMode.system;
  int _currentThemeIndex = 0;

  /// The current [ThemeMode] (light / dark / system).
  ThemeMode get themeMode => _themeMode;

  /// Index into [AppThemes.customSchemes] for the active color scheme.
  int get currentThemeIndex => _currentThemeIndex;

  /// The currently selected [FlexSchemeData] scheme.
  FlexSchemeData get currentTheme => AppThemes.customSchemes[_currentThemeIndex];

  /// Loads persisted theme mode and scheme index from [ThemeService].
  Future<void> loadSettings() async {
    _themeMode = await _themeService.loadThemeMode();
    _currentThemeIndex = await _themeService.loadThemeScheme();
    if (_currentThemeIndex < 0 || _currentThemeIndex >= AppThemes.customSchemes.length) {
      _currentThemeIndex = 0;
    }
    notifyListeners();
  }

  /// Updates the theme mode and persists it via [ThemeService].
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _themeService.saveThemeMode(newThemeMode);
  }

  /// Updates the color scheme index and persists it via [ThemeService].
  Future<void> updateThemeScheme(int? newIndex) async {
    if (newIndex == null || newIndex == _currentThemeIndex) return;
    if (newIndex < 0 || newIndex >= AppThemes.customSchemes.length) return;
    _currentThemeIndex = newIndex;
    notifyListeners();
    await _themeService.saveThemeScheme(newIndex);
  }
}
