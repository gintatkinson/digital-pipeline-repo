import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class DesignTokenRegistry {
  dynamic getRawToken(String path);
  Color getColor(String path, {String? theme});
  double getDimension(String path);
  String getString(String path);

  static final DesignTokenRegistry defaultRegistry = AppDesignTokenRegistry.parse(defaultDesignTokensJson);
}

const String defaultDesignTokensJson = '''
{
  "global": {
    "color": {
      "blue-500": { "\$value": "#1a73e8", "\$type": "color" },
      "blue-600": { "\$value": "#1557b0", "\$type": "color" },
      "white": { "\$value": "#ffffff", "\$type": "color" },
      "black-12": { "\$value": "#121212", "\$type": "color" },
      "gray-100": { "\$value": "#f1f3f4", "\$type": "color" },
      "gray-900": { "\$value": "#202124", "\$type": "color" }
    },
    "spacing": {
      "xs": { "\$value": "4px", "\$type": "dimension" },
      "sm": { "\$value": "8px", "\$type": "dimension" },
      "md": { "\$value": "16px", "\$type": "dimension" },
      "lg": { "\$value": "24px", "\$type": "dimension" },
      "layout-sidebar-width": { "\$value": "280px", "\$type": "dimension" },
      "layout-min-pane-size": { "\$value": "150px", "\$type": "dimension" }
    },
    "typography": {
      "font-family": { "\$value": "Outfit, Roboto, sans-serif", "\$type": "fontFamily" },
      "scale": { "\$value": "high-density", "\$type": "string" }
    }
  },
  "alias": {
    "color": {
      "brand-primary": { "\$value": "{global.color.blue-500}", "\$type": "color" },
      "brand-primary-hover": { "\$value": "{global.color.blue-600}", "\$type": "color" },
      "background": {
        "\$value": {
          "light": "{global.color.white}",
          "dark": "{global.color.black-12}"
        },
        "\$type": "color"
      },
      "surface": {
        "\$value": {
          "light": "{global.color.gray-100}",
          "dark": "{global.color.gray-900}"
        },
        "\$type": "color"
      }
    },
    "spacing": {
      "xs": { "\$value": "{global.spacing.xs}", "\$type": "dimension" },
      "sm": { "\$value": "{global.spacing.sm}", "\$type": "dimension" },
      "md": { "\$value": "{global.spacing.md}", "\$type": "dimension" },
      "lg": { "\$value": "{global.spacing.lg}", "\$type": "dimension" },
      "layout-sidebar-width": { "\$value": "{global.spacing.layout-sidebar-width}", "\$type": "dimension" },
      "layout-min-pane-size": { "\$value": "{global.spacing.layout-min-pane-size}", "\$type": "dimension" }
    },
    "typography": {
      "font-family": { "\$value": "{global.typography.font-family}", "\$type": "fontFamily" },
      "scale": { "\$value": "{global.typography.scale}", "\$type": "string" }
    }
  },
  "component": {
    "sidebar": {
      "width": { "\$value": "{alias.spacing.layout-sidebar-width}", "\$type": "dimension" }
    },
    "splitter": {
      "min-pane-size": { "\$value": "{alias.spacing.layout-min-pane-size}", "\$type": "dimension" }
    },
    "button": {
      "background": { "\$value": "{alias.color.brand-primary}", "\$type": "color" },
      "background-hover": { "\$value": "{alias.color.brand-primary-hover}", "\$type": "color" }
    }
  }
}
''';

class AppDesignTokenRegistry implements DesignTokenRegistry {
  final Map<String, dynamic> _tokens;

  AppDesignTokenRegistry(this._tokens);

  static AppDesignTokenRegistry parse(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    return AppDesignTokenRegistry(data);
  }

  dynamic _resolve(dynamic node, {String? theme}) {
    if (node == null) return null;
    if (node is Map<String, dynamic>) {
      if (node.containsKey('\$value')) {
        final val = node['\$value'];
        return _resolve(val, theme: theme);
      }
      if (theme != null && node.containsKey(theme)) {
        return _resolve(node[theme], theme: theme);
      }
      return node;
    }

    if (node is String) {
      final strVal = node.trim();
      if (strVal.startsWith('{') && strVal.endsWith('}')) {
        final path = strVal.substring(1, strVal.length - 1);
        final refNode = _getNodeByPath(path);
        return _resolve(refNode, theme: theme);
      }
      return strVal;
    }

    return node;
  }

  dynamic _getNodeByPath(String path) {
    final parts = path.split('.');
    dynamic current = _tokens;
    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  @override
  dynamic getRawToken(String path) {
    final node = _getNodeByPath(path);
    return _resolve(node);
  }

  @override
  Color getColor(String path, {String? theme}) {
    final node = _getNodeByPath(path);
    final resolved = _resolve(node, theme: theme);
    if (resolved is String) {
      return _parseColor(resolved);
    }
    if (resolved is Color) return resolved;
    if (resolved is int) return Color(resolved);
    throw Exception('Token at path $path with theme $theme is not a color: $resolved');
  }

  Color _parseColor(String colorStr) {
    var hex = colorStr.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final val = int.tryParse(hex, radix: 16);
    if (val != null) {
      return Color(val);
    }
    return Colors.transparent;
  }

  @override
  double getDimension(String path) {
    final node = _getNodeByPath(path);
    final resolved = _resolve(node);
    if (resolved is num) {
      return resolved.toDouble();
    }
    if (resolved is String) {
      final clean = resolved.replaceAll(RegExp(r'[a-zA-Z%]+'), '').trim();
      final val = double.tryParse(clean);
      if (val != null) return val;
    }
    throw Exception('Token at path $path is not a dimension: $resolved');
  }

  @override
  String getString(String path) {
    final node = _getNodeByPath(path);
    final resolved = _resolve(node);
    return resolved?.toString() ?? '';
  }
}

class DesignTokenProvider extends StatelessWidget {
  final DesignTokenRegistry registry;
  final Widget child;

  const DesignTokenProvider({
    super.key,
    required this.registry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<DesignTokenRegistry>.value(
      value: registry,
      child: child,
    );
  }
}
