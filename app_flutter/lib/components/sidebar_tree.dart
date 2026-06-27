import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/components/tree_node_widget.dart';
import 'package:app_flutter/domain/design_tokens.dart';

class SidebarTree extends StatefulWidget {
  final List<TreeNode> treeData;
  final String currentView;
  final int? workerResult;
  final String themeMode;
  final ValueChanged<String> onViewSelected;
  final ValueChanged<String>? onThemeModeChange;

  const SidebarTree({
    super.key,
    required this.treeData,
    required this.currentView,
    this.workerResult,
    required this.themeMode,
    required this.onViewSelected,
    this.onThemeModeChange,
  });

  @override
  State<SidebarTree> createState() => _SidebarTreeState();
}

class _SidebarTreeState extends State<SidebarTree> {
  final Map<String, bool> _expanded = {
    'Monitoring': true,
    'Spec': true,
  };
  final FocusNode _treeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _expandParents(widget.currentView);
  }

  @override
  void didUpdateWidget(covariant SidebarTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentView != oldWidget.currentView) {
      _expandParents(widget.currentView);
    }
  }

  @override
  void dispose() {
    _treeFocusNode.dispose();
    super.dispose();
  }

  void _expandParents(String targetView) {
    bool changed = false;
    bool findAndExpandParents(List<TreeNode> nodes, String targetId, List<String> path) {
      for (final node in nodes) {
        if (node.id == targetId) {
          for (final id in path) {
            if (_expanded[id] != true) {
              _expanded[id] = true;
              changed = true;
            }
          }
          return true;
        }
        if (node.children != null) {
          if (findAndExpandParents(node.children!, targetId, [...path, node.id])) {
            return true;
          }
        }
      }
      return false;
    }

    findAndExpandParents(widget.treeData, targetView, []);
    if (changed) {
      setState(() {});
    }
  }

  List<TreeNode> _getVisibleNodes(List<TreeNode> nodes) {
    final List<TreeNode> result = [];
    void traverse(TreeNode node) {
      result.add(node);
      if (node.children != null && _expanded[node.id] == true) {
        node.children!.forEach(traverse);
      }
    }
    nodes.forEach(traverse);
    return result;
  }

  void _handleArrowDown() {
    final visible = _getVisibleNodes(widget.treeData);
    final currentIndex = visible.indexWhere((n) => n.id == widget.currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      _selectView(visible[nextIndex].id);
    }
  }

  void _handleArrowUp() {
    final visible = _getVisibleNodes(widget.treeData);
    final currentIndex = visible.indexWhere((n) => n.id == widget.currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      _selectView(visible[prevIndex].id);
    }
  }

  void _handleArrowRight() {
    final visible = _getVisibleNodes(widget.treeData);
    final currentIndex = visible.indexWhere((n) => n.id == widget.currentView);
    if (currentIndex == -1) return;
    final currentNode = visible[currentIndex];
    if (currentNode.children != null && currentNode.children!.isNotEmpty) {
      if (_expanded[currentNode.id] != true) {
        setState(() {
          _expanded[currentNode.id] = true;
        });
      } else {
        final firstChild = currentNode.children![0];
        _selectView(firstChild.id);
      }
    }
  }

  void _handleArrowLeft() {
    final visible = _getVisibleNodes(widget.treeData);
    final currentIndex = visible.indexWhere((n) => n.id == widget.currentView);
    if (currentIndex == -1) return;
    final currentNode = visible[currentIndex];
    if (currentNode.children != null &&
        currentNode.children!.isNotEmpty &&
        _expanded[currentNode.id] == true) {
      setState(() {
        _expanded[currentNode.id] = false;
      });
    } else {
      TreeNode? findParent(List<TreeNode> nodes, String targetId, TreeNode? parent) {
        for (final node in nodes) {
          if (node.id == targetId) return parent;
          if (node.children != null) {
            final found = findParent(node.children!, targetId, node);
            if (found != null) return found;
          }
        }
        return null;
      }

      final parent = findParent(widget.treeData, currentNode.id, null);
      if (parent != null) {
        _selectView(parent.id);
      }
    }
  }

  void _selectView(String viewId) {
    _expandParents(viewId);
    widget.onViewSelected(viewId);
  }

  @override
  Widget build(BuildContext context) {
    final registry = DesignTokenProvider.of(context);
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
              focusNode: _treeFocusNode,
              autofocus: true,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent) {
                  final key = event.logicalKey;
                  if (key == LogicalKeyboardKey.arrowDown) {
                    _handleArrowDown();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowUp) {
                    _handleArrowUp();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowLeft) {
                    _handleArrowLeft();
                    return KeyEventResult.handled;
                  } else if (key == LogicalKeyboardKey.arrowRight) {
                    _handleArrowRight();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.treeData.map((node) => TreeNodeWidget(
                    node: node,
                    expanded: _expanded,
                    focusNode: _treeFocusNode,
                    currentView: widget.currentView,
                    onTap: _selectView,
                    onToggle: (id) {
                      setState(() {
                        _expanded[id] = !(_expanded[id] ?? false);
                      });
                    },
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
                        'Worker: ${widget.workerResult ?? "Idle"}',
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
                          value: widget.themeMode,
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
                              widget.onThemeModeChange?.call(val);
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
