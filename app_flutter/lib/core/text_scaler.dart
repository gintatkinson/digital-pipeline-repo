import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages a user-adjustable text scale factor, persisted via
/// [SharedPreferences].
///
/// The scale is clamped to `[0.7, 1.5]`. [load] must be called once
/// after construction to restore the persisted value (defaults to
/// `1.0`). [setScale] fires [notifyListeners] before persisting so the
/// UI responds immediately.
class TextScaleController extends ChangeNotifier {
  static const _min = 0.7;
  static const _max = 1.5;
  static const _default = 1.0;
  static const _key = 'text_scale_factor';

  double _scale = _default;

  double get scale => _scale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_key);
    _scale = stored?.clamp(_min, _max) ?? _default;
    notifyListeners();
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(_min, _max);
    if (clamped == _scale) return;
    _scale = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, clamped);
    notifyListeners();
  }
}
