import 'package:flutter/material.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

/// View-model for the navigation tree. Manages expansion state,
/// keyboard navigation, and the currently selected view.
class TreeViewModel extends ChangeNotifier {
  final List<TreeNode> treeData;
  String _currentView;
  final Map<String, bool> _expanded = {};
  final FocusNode _treeFocusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};
  final ValueChanged<String>? onViewSelected;

  TreeViewModel({
    required this.treeData,
    required String initialView,
    this.onViewSelected,
  }) : _currentView = initialView {
    _initExpandedFromTree();
    _expandParents(initialView);
    _buildNodeKeys(treeData);
  }

  /// The ID of the currently selected/active view.
  String get currentView => _currentView;

  /// Map of node IDs to their expanded state.
  Map<String, bool> get expanded => _expanded;

  /// [FocusNode] associated with the tree widget.
  FocusNode get focusNode => _treeFocusNode;

  /// Returns the [GlobalKey] for the node with the given [id].
  GlobalKey? nodeKey(String id) => _nodeKeys[id];

  /// Selects [viewId] as the current view, expanding parents and scrolling.
  void selectView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
    onViewSelected?.call(viewId);
  }

  /// Updates the current view without calling [onViewSelected].
  void updateCurrentView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
  }

  /// Toggles the expanded state of the node with the given [id].
  void toggleExpand(String id) {
    _expanded[id] = !(_expanded[id] ?? false);
    notifyListeners();
  }

  /// Moves selection to the next visible node.
  void handleArrowDown() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      selectView(visible[nextIndex].id);
    }
  }

  /// Moves selection to the previous visible node.
  void handleArrowUp() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      selectView(visible[prevIndex].id);
    }
  }

  /// Expands the current node or moves to its first child.
  void handleArrowRight() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    if (currentIndex == -1) return;
    final currentNode = visible[currentIndex];
    if (currentNode.children != null && currentNode.children!.isNotEmpty) {
      if (_expanded[currentNode.id] != true) {
        _expanded[currentNode.id] = true;
        notifyListeners();
      } else {
        final firstChild = currentNode.children![0];
        selectView(firstChild.id);
      }
    }
  }

  /// Collapses the current node or moves to its parent.
  void handleArrowLeft() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    if (currentIndex == -1) return;
    final currentNode = visible[currentIndex];
    if (currentNode.children != null &&
        currentNode.children!.isNotEmpty &&
        _expanded[currentNode.id] == true) {
      _expanded[currentNode.id] = false;
      notifyListeners();
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

      final parent = findParent(treeData, currentNode.id, null);
      if (parent != null) {
        selectView(parent.id);
      }
    }
  }

  /// Disposes the tree focus node.
  @override
  void dispose() {
    _treeFocusNode.dispose();
    super.dispose();
  }


  void _buildNodeKeys(List<TreeNode> nodes) {
    for (final node in nodes) {
      _nodeKeys[node.id] = GlobalKey();
      if (node.children != null) {
        _buildNodeKeys(node.children!);
      }
    }
  }

  void _initExpandedFromTree() {
    for (final node in treeData) {
      if (node.children != null && node.children!.isNotEmpty) {
        _expanded[node.id] = true;
      }
    }
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

    findAndExpandParents(treeData, targetView, []);
    if (changed) {
      notifyListeners();
    }
  }

  List<TreeNode> _getVisibleNodes() {
    final List<TreeNode> result = [];
    void traverse(TreeNode node) {
      result.add(node);
      if (node.children != null && _expanded[node.id] == true) {
        node.children!.forEach(traverse);
      }
    }
    treeData.forEach(traverse);
    return result;
  }

  void _scrollToNode(String viewId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _nodeKeys[viewId]?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
