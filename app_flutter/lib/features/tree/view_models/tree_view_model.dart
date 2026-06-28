import 'package:flutter/material.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

class TreeViewModel extends ChangeNotifier {
  final List<TreeNode> treeData;
  String _currentView;
  final Map<String, bool> _expanded = {};
  final FocusNode _treeFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
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

  String get currentView => _currentView;
  Map<String, bool> get expanded => _expanded;
  FocusNode get focusNode => _treeFocusNode;
  ScrollController get scrollController => _scrollController;
  GlobalKey? nodeKey(String id) => _nodeKeys[id];

  void selectView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
    onViewSelected?.call(viewId);
  }

  void updateCurrentView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
  }

  void toggleExpand(String id) {
    _expanded[id] = !(_expanded[id] ?? false);
    notifyListeners();
  }

  void handleArrowDown() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      selectView(visible[nextIndex].id);
    }
  }

  void handleArrowUp() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      selectView(visible[prevIndex].id);
    }
  }

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

  @override
  void dispose() {
    _treeFocusNode.dispose();
    _scrollController.dispose();
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
