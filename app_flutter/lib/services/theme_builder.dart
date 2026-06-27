import 'package:flutter/material.dart';
import 'package:app_flutter/domain/design_tokens.dart';

ThemeData buildThemeFromTokens(DesignTokenRegistry registry, bool isDark) {
  final theme = isDark ? 'dark' : 'light';
  final primary = registry.getColor('alias.color.brand-primary', theme: theme);
  final bg = registry.getColor('alias.color.background', theme: theme);
  final surface = registry.getColor('alias.color.surface', theme: theme);
  final divider = registry.getColor(isDark ? 'global.color.gray-900' : 'global.color.gray-100');

  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: bg,
    cardColor: surface,
    dividerColor: divider,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
}
