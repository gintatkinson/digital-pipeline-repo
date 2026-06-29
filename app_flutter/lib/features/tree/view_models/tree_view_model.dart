import 'package:flutter/material.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

class TreeViewModel extends ChangeNotifier {
  TreeViewModel(this._dataSource, {
    String initialView = '',
    this.onViewSelected,
  }) : _currentView = initialView;

  final DataSource _dataSource;
  final ValueChanged<String>? onViewSelected;
  List<TreeNode> _treeData = [];
  String _currentView;
  final Map<String, bool> _expanded = {};
  final FocusNode _treeFocusNode = FocusNode();
  final Map<String, GlobalKey> _nodeKeys = {};

  List<TreeNode> get treeData => _treeData;
  String get currentView => _currentView;
  Map<String, bool> get expanded => _expanded;
  FocusNode get focusNode => _treeFocusNode;
  GlobalKey? nodeKey(String id) => _nodeKeys[id];

  Future<void> loadTree() async {
    final types = await _dataSource.discoverTypes();
    final hierarchy = await _dataSource.discoverHierarchy();
    _treeData = _buildTree(types, hierarchy);

    if (_currentView.isEmpty && _treeData.isNotEmpty) {
      _currentView = _treeData.first.id;
    }

    _initExpandedFromTree();
    _expandParents(_currentView);
    _buildNodeKeys(_treeData);
    notifyListeners();
  }

  List<TreeNode> _buildTree(List<TypeDescriptor> types, List<(String, String)> hierarchy) {
    final typeMap = {for (final t in types) t.typeName: t};
    final children = <String, List<TreeNode>>{};
    final hasParent = <String>{};

    for (final (parent, child) in hierarchy) {
      children.putIfAbsent(parent, () => []);
      if (typeMap.containsKey(child)) {
        children[parent]!.add(TreeNode(id: child, label: typeMap[child]!.displayName));
        hasParent.add(child);
      }
    }

    return types
        .where((t) => !hasParent.contains(t.typeName))
        .map((t) => TreeNode(
              id: t.typeName,
              label: t.displayName,
              children: children[t.typeName],
            ))
        .toList();
  }

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

      final parent = findParent(_treeData, currentNode.id, null);
      if (parent != null) {
        selectView(parent.id);
      }
    }
  }

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
    for (final node in _treeData) {
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

    findAndExpandParents(_treeData, targetView, []);
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
    _treeData.forEach(traverse);
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
