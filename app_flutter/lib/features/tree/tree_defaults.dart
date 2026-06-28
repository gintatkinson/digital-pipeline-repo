import 'package:app_flutter/features/tree/tree_node.dart';

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
      TreeNode(id: 'Uptime', label: 'Uptime'),
    ],
  ),
  TreeNode(
    id: 'Spec',
    label: 'Spec',
    children: [
      TreeNode(id: 'Epics', label: 'Epics'),
      TreeNode(id: 'Traceability', label: 'Traceability'),
      TreeNode(id: 'Requirements', label: 'Requirements'),
      TreeNode(id: 'Releases', label: 'Releases'),
    ],
  ),
  TreeNode(
    id: 'Security',
    label: 'Security',
    children: [
      TreeNode(id: 'Access', label: 'Access'),
      TreeNode(id: 'Firewall', label: 'Firewall'),
      TreeNode(id: 'Certificates', label: 'Certificates'),
      TreeNode(id: 'Audit', label: 'Audit'),
    ],
  ),
  TreeNode(
    id: 'Infrastructure',
    label: 'Infrastructure',
    children: [
      TreeNode(id: 'Servers', label: 'Servers'),
      TreeNode(id: 'Storage', label: 'Storage'),
      TreeNode(id: 'Network', label: 'Network'),
    ],
  ),
];
