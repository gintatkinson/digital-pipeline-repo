import 'dart:async';
import 'package:flutter/material.dart';
import 'theme_service.dart';

/// Manages a clamped text scale factor and persists it via [ThemeService].
class TextScalerController extends ChangeNotifier {
  TextScalerController([this._themeService]);
  final ThemeService? _themeService;
  double _scale = 1.0;

  /// The current text scale factor (clamped 0.7–1.5).
  double get scale => _scale;

  /// Loads the persisted scale factor from [ThemeService].
  Future<void> load() async {
    _scale = await _themeService?.loadTextScale() ?? 1.0;
    notifyListeners();
  }

  /// Sets the scale factor (clamped 0.7–1.5) and persists it.
  void setScale(double value) {
    _scale = value.clamp(0.7, 1.5);
    notifyListeners();
    unawaited(_themeService?.saveTextScale(_scale).catchError((Object e) {
      debugPrint('Failed to save text scale: $e');
    }));
  }
}
