import 'package:flutter/material.dart';
import 'package:pipeline_app/features/tree/tree_view_model.dart';

/// Sidebar panel with a header bar, scrollable instance list, and
/// footer containing a settings gear icon that opens a bottom sheet.
class TreeSidebar extends StatelessWidget {
  final TreeViewModel viewModel;
  final ValueChanged<String> onNodeSelected;
  final VoidCallback onSettingsPressed;

  const TreeSidebar({
    super.key,
    required this.viewModel,
    required this.onNodeSelected,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_board, color: cs.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Navigator', style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                final nodes = viewModel.nodes;
                final selected = viewModel.selectedNodeId;
                return ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    final isSelected = node.nodeId == selected;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: cs.primaryContainer,
                      title: Text(node.displayLabel, style: const TextStyle(fontSize: 13)),
                      onTap: () {
                        viewModel.selectNode(node.nodeId);
                        onNodeSelected(node.nodeId);
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: cs.tertiary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Ready', style: Theme.of(context).textTheme.bodySmall),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 18),
                  onPressed: onSettingsPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
