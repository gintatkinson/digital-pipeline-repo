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
