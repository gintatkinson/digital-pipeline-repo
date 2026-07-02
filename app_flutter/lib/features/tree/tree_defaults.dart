import 'package:app_flutter/features/tree/tree_node.dart';

/// Fallback tree data used when DataSource returns no hierarchy.
/// Replace with your domain's actual tree structure.
const List<TreeNode> defaultTreeData = [
  TreeNode(id: 'Master_A', label: 'Master A'),
  TreeNode(id: 'Master_B', label: 'Master B'),
  TreeNode(id: 'Master_C', label: 'Master C'),
];
