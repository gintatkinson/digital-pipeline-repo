import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/config/tree_defaults.dart';

Future<Map<String, dynamic>> loadLayoutConfig(String assetPath) async {
  final jsonStr = await rootBundle.loadString(assetPath);
  return jsonDecode(jsonStr) as Map<String, dynamic>;
}

List<TreeNode> parseTreeHierarchy(Map<String, dynamic> layoutConfig) {
  try {
    Map<String, dynamic>? findHierarchyTreeSelector(Map<String, dynamic>? node) {
      if (node == null) return null;
      if (node['type'] == 'HierarchyTreeSelector') {
        return node;
      }
      final children = node['children'];
      if (children is List) {
        for (final child in children) {
          if (child is Map<String, dynamic>) {
            final found = findHierarchyTreeSelector(child);
            if (found != null) return found;
          }
        }
      }
      return null;
    }

    final layout = layoutConfig['layout'];
    if (layout is! Map<String, dynamic>) {
      return defaultTreeData;
    }
    final rootContainer = layout['root_container'];
    if (rootContainer is! Map<String, dynamic>) {
      return defaultTreeData;
    }

    final selector = findHierarchyTreeSelector(rootContainer);
    if (selector == null) {
      return defaultTreeData;
    }

    final props = selector['props'];
    if (props is! Map<String, dynamic>) {
      return defaultTreeData;
    }

    final hierarchy = props['hierarchy'];
    if (hierarchy is! List) {
      return defaultTreeData;
    }

    List<TreeNode> parseNodes(List<dynamic> jsonList) {
      final List<TreeNode> list = [];
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final id = item['id'];
          final label = item['label'];
          if (id is String && label is String) {
            List<TreeNode>? children;
            if (item['children'] is List) {
              children = parseNodes(item['children'] as List<dynamic>);
            }
            list.add(TreeNode(id: id, label: label, children: children));
          }
        }
      }
      return list;
    }

    final parsed = parseNodes(hierarchy);
    if (parsed.isEmpty) {
      return defaultTreeData;
    }
    return parsed;
  } catch (_) {
    return defaultTreeData;
  }
}
