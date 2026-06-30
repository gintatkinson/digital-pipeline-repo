import 'dart:convert';
import 'package:flutter/services.dart';

/// Runtime-loaded string resources.
///
/// All UI display strings come from assets/strings.json so they can be
/// changed without modifying source code. Load once at startup in main().
class StringResources {
  static Map<String, String> _strings = {};

  static Future<void> load() async {
    final json = await rootBundle.loadString('assets/strings.json');
    _strings = Map<String, String>.from(jsonDecode(json) as Map);
  }

  static String get(String key, {String? fallback}) =>
      _strings[key] ?? fallback ?? key;

  /// Load strings from a raw JSON string (useful in tests).
  static void loadFromJson(String json) {
    _strings = Map<String, String>.from(jsonDecode(json) as Map);
  }
}
