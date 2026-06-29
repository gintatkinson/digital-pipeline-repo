import 'dart:async';
import 'package:flutter/material.dart';
import 'theme_service.dart';

class TextScalerController extends ChangeNotifier {
  TextScalerController([this._themeService]);
  final ThemeService? _themeService;
  double _scale = 1.0;

  double get scale => _scale;

  Future<void> load() async {
    _scale = await _themeService?.loadTextScale() ?? 1.0;
    notifyListeners();
  }

  void setScale(double value) {
    _scale = value.clamp(0.7, 1.5);
    notifyListeners();
    unawaited(_themeService?.saveTextScale(_scale).catchError((Object e) {
      debugPrint('Failed to save text scale: $e');
    }));
  }
}
