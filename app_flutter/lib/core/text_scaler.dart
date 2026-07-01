import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextScaler extends ChangeNotifier {
  static const double _minScale = 0.7;
  static const double _maxScale = 1.5;
  static const double _defaultScale = 1.0;
  static const String _storageKey = 'text_scale_factor';

  double _scale = _defaultScale;

  double get scale => _scale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_storageKey);
    if (stored != null) {
      _scale = stored.clamp(_minScale, _maxScale);
    } else {
      _scale = _defaultScale;
    }
    notifyListeners();
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(_minScale, _maxScale);
    if (clamped == _scale) return;
    _scale = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_storageKey, clamped);
    notifyListeners();
  }
}
