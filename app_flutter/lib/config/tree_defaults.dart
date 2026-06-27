import 'package:app_flutter/components/tree_node.dart';

// TODO(#79): Replace mock tree data with dynamic DB-backed data.
// Currently used as fallback when layout config parsing fails or is missing.
const List<TreeNode> defaultTreeData = [
  TreeNode(id: 'Ingestion', label: 'Ingestion'),
  TreeNode(
    id: 'Monitoring',
    label: 'Monitoring',
    children: [
      TreeNode(id: 'Metrics', label: 'Metrics'),
      TreeNode(id: 'Location', label: 'Location'),
      TreeNode(id: 'Chassis', label: 'Chassis'),
    ],
  ),
  TreeNode(
    id: 'Spec',
    label: 'Spec',
    children: [
      TreeNode(id: 'Epics', label: 'Epics'),
      TreeNode(id: 'Traceability', label: 'Traceability'),
    ],
  ),
];
