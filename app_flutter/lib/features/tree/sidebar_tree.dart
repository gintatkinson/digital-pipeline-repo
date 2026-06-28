import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/tree_node_widget.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
import 'package:app_flutter/core/design_tokens.dart';

class SidebarTree extends StatelessWidget {
  final List<TreeNode> treeData;
  final int? workerResult;
  final String themeMode;
  final ValueChanged<String> onViewSelected;
  final ValueChanged<String>? onThemeModeChange;

  const SidebarTree({
    super.key,
    required this.treeData,
    this.workerResult,
    required this.themeMode,
    required this.onViewSelected,
    this.onThemeModeChange,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TreeViewModel>();
    final registry = context.watch<DesignTokenRegistry>();
    final brandPrimary = registry.getColor('alias.color.brand-primary');
    final whiteColor = registry.getColor('global.color.white');

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
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [brandPrimary, brandPrimary.withValues(alpha: 0.7)],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.developer_board,
                    color: whiteColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Antigravity Console',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
                  controller: viewModel.scrollController,
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black38
                  : Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Worker status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Worker: ${workerResult ?? "Idle"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Theme selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.brightness_medium, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          value: themeMode,
                          isDense: true,
                          underline: const SizedBox(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          items: const [
                            DropdownMenuItem(value: 'light', child: Text('Light')),
                            DropdownMenuItem(value: 'dark', child: Text('Dark')),
                            DropdownMenuItem(value: 'system', child: Text('System')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              onThemeModeChange?.call(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
