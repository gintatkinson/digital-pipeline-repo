/// TreeNode representing hierarchy selector items
class TreeNode {
  final String id;
  final String label;
  final List<TreeNode>? children;

  const TreeNode({
    required this.id,
    required this.label,
    this.children,
  });
}

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
