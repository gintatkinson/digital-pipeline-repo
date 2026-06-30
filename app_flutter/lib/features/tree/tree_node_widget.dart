import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';

/// Renders a single [TreeNode] row in the sidebar tree with expand/collapse
/// and selection highlighting.
///
/// Recursively renders child nodes indented under their parent when expanded.
/// Selection state is read from [TreeViewModel.currentView]; expansion state
/// from [TreeViewModel.expanded]. Tapping a leaf node calls
/// [TreeViewModel.selectView], while parent nodes show a toggle handle to
/// expand/collapse children.
///
/// Edge cases: root-level nodes with no parent; nodes whose parent is
/// collapsed are not rendered on screen (filtered by [TreeViewModel]'s
/// visible-node walk). Does not trigger [notifyListeners] directly — all
/// state changes are delegated to the view model.
class TreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final double childIndent;

  const TreeNodeWidget({
    super.key,
    required this.node,
    this.childIndent = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreeViewModel>();
    final isSelected = viewModel.currentView == node.id;
    final isParent = node.children != null && node.children!.isNotEmpty;
    final isExpanded = viewModel.expanded[node.id] == true;

    IconData icon;
    if (isParent) {
      icon = isExpanded ? Icons.folder_open : Icons.folder;
    } else {
      icon = Icons.insert_drive_file;
    }

    final brandPrimary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          key: viewModel.nodeKey(node.id),
          type: MaterialType.transparency,
          child: ListTile(
          key: Key('node_${node.id}'),
          dense: true,
          selected: isSelected,
          selectedTileColor: brandPrimary.withValues(alpha: 0.12),
          leading: Icon(
            icon,
            size: 16,
            color: isSelected
                ? brandPrimary
                : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          title: Text(
            node.label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: isParent
              ? InkWell(
                  key: Key('toggle_${node.id}'),
                  onTap: () {
                    viewModel.toggleExpand(node.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      isExpanded ? '−' : '+',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                )
              : null,
          onTap: () {
            viewModel.selectView(node.id);
            viewModel.focusNode.requestFocus();
          },
        ),
          ),
        if (isParent && isExpanded)
          Padding(
            padding: EdgeInsets.only(left: childIndent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: node.children!.map((child) => TreeNodeWidget(
                node: child,
              )).toList(),
            ),
          ),
      ],
    );
  }
}
