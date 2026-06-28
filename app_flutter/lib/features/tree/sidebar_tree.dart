import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/core/theme/widgets/settings_panel.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/tree_node_widget.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
class SidebarTree extends StatelessWidget {
  final List<TreeNode> treeData;
  final int? workerResult;
  final ValueChanged<String> onViewSelected;

  const SidebarTree({
    super.key,
    required this.treeData,
    this.workerResult,
    required this.onViewSelected,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreeViewModel>();
    final brandPrimary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.developer_board,
                  color: brandPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Antigravity Console',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          // Focusable Tree Navigation
          Expanded(
            child: Focus(
              focusNode: viewModel.focusNode,
              autofocus: true,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent) {
                  final key = event.logicalKey;
                  if (key == LogicalKeyboardKey.arrowDown) {
                    viewModel.handleArrowDown();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowUp) {
                    viewModel.handleArrowUp();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowLeft) {
                    viewModel.handleArrowLeft();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowRight) {
                    viewModel.handleArrowRight();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
                child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: treeData.map((node) => TreeNodeWidget(
                    node: node,
                  )).toList(),
                ),
              ),
            ),
          ),
          // Sidebar Footer
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Worker: ${workerResult ?? "Idle"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, size: 18),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const SettingsPanel(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
