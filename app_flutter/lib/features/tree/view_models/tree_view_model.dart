import 'package:flutter/material.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/tree/tree_node.dart';

/// View model driving the sidebar tree: data loading, navigation, focus,
/// and keyboard-driven expansion/selection.
///
/// Owns the tree data ([_treeData]), the currently-selected view
/// ([_currentView]), per-node expand/collapse state ([_expanded]), and a
/// [FocusNode] for keyboard event handling. Calls [notifyListeners] after
/// every mutation to trigger UI rebuilds via [Provider].
///
/// State changes: [loadTree] resets the entire tree; [selectView] /
/// [updateCurrentView] change the current view and expand ancestors;
/// [toggleExpand] flips a single node's collapsed state; arrow handlers
/// traverse the visible (depth-first) node list. On dispose, the focus node
/// is released.
///
/// Edge cases: empty tree data, missing node IDs in arrow navigation (index
/// -1 is handled), root nodes with no parents to expand, and views whose
/// parent chain is already visible (no-op expand).
class TreeViewModel extends ChangeNotifier {
  static const _excludedTypes = {'Detail_A', 'Detail_B', 'Detail_C'};

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

  /// Loads the type hierarchy from the data source and initialises tree data,
  /// current view, expanded nodes, and node keys.
  ///
  /// Called once during startup. Sets [_currentView] to the first root node if
  /// no initial view was provided. Ensures the path to the current view is
  /// expanded. Fires [notifyListeners] when complete.
  ///
  /// Safe to call multiple times; resets all state before rebuilding.
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

  /// Builds a forest of [TreeNode]s from [types] and [hierarchy] edges.
  ///
  /// Root nodes are types that appear in [types] but have no parent in either
  /// the hierarchy list or the `parentTypes` field. Nodes with children link
  /// to their sub-tree via [TreeNode.children].
  ///
  /// Mutations: writes [_treeData] on the parent object. No [notifyListeners]
  /// call — the caller ([loadTree]) is responsible.
  List<TreeNode> _buildTree(List<TypeDescriptor> types, List<(String, String)> hierarchy) {
    final typeMap = {
      for (final t in types)
        if (!_excludedTypes.contains(t.typeName)) t.typeName: t
    };
    final children = <String, List<TreeNode>>{};
    final hasParent = <String>{};

    for (final (parent, child) in hierarchy) {
      if (_excludedTypes.contains(parent) || _excludedTypes.contains(child)) {
        continue;
      }
      children.putIfAbsent(parent, () => []);
      if (typeMap.containsKey(child)) {
        final exists = children[parent]!.any((n) => n.id == child);
        if (!exists) {
          children[parent]!.add(TreeNode(id: child, label: typeMap[child]!.displayName));
          hasParent.add(child);
        }
      }
    }

    // Build children from childTypes (used for tree hierarchy)
    for (final type in types) {
      if (_excludedTypes.contains(type.typeName)) continue;
      for (final ct in type.childTypes) {
        final childName = ct.childTypeName;
        if (_excludedTypes.contains(childName)) continue;
        if (typeMap.containsKey(childName)) {
          children.putIfAbsent(type.typeName, () => []);
          final exists = children[type.typeName]!.any((n) => n.id == childName);
          if (!exists) {
            children[type.typeName]!.add(TreeNode(id: childName, label: typeMap[childName]!.displayName));
            hasParent.add(childName);
          }
        }
      }
    }

    // Types referenced in parentTypes also have parents
    for (final type in types) {
      if (_excludedTypes.contains(type.typeName)) continue;
      for (final pt in type.parentTypes) {
        if (_excludedTypes.contains(pt.childTypeName)) continue;
        hasParent.add(type.typeName);
      }
    }

    return types
        .where((t) => !_excludedTypes.contains(t.typeName) && !hasParent.contains(t.typeName))
        .map((t) => TreeNode(
              id: t.typeName,
              label: t.displayName,
              children: children[t.typeName],
            ))
        .toList();
  }

  /// Selects [viewId] as the current view, expands its ancestors, scrolls it
  /// into view, and notifies listeners.
  ///
  /// Called when the user taps a tree node or navigates via arrow keys. No-op
  /// if [viewId] is already the current view. Triggers [onViewSelected]
  /// callback after state is updated.
  void selectView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
    onViewSelected?.call(viewId);
  }

  /// Updates the current view (without firing [selectView]'s external callback).
  ///
  /// Used by [Layout._updateCurrentViewFromLayout] when the active view is
  /// driven externally (e.g. via widget properties). Expands ancestors and
  /// scrolls to the node, then fires [notifyListeners]. No-op if [viewId]
  /// matches the current view.
  void updateCurrentView(String viewId) {
    if (_currentView == viewId) return;
    _currentView = viewId;
    _expandParents(viewId);
    _scrollToNode(viewId);
    notifyListeners();
  }

  /// Toggles expansion state of the node with [id].
  ///
  /// Flips the boolean in [_expanded] (defaults to expanded if not set).
  /// Fires [notifyListeners] unconditionally. Safe to call on leaf nodes
  /// (stores a value that is never read by [_getVisibleNodes] since leaves
  /// have no children).
  void toggleExpand(String id) {
    _expanded[id] = !(_expanded[id] ?? false);
    notifyListeners();
  }

  /// Moves selection to the next visible node (depth-first order).
  ///
  /// Called on ArrowDown key event. No-op if the current node is the last
  /// visible node.
  void handleArrowDown() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      selectView(visible[nextIndex].id);
    }
  }

  /// Moves selection to the previous visible node (depth-first order).
  ///
  /// Called on ArrowUp key event. No-op if the current node is the first
  /// visible node.
  void handleArrowUp() {
    final visible = _getVisibleNodes();
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      selectView(visible[prevIndex].id);
    }
  }

  /// Expands the current node or, if already expanded, selects its first child.
  ///
  /// Called on ArrowRight key event. If the current node has no children this
  /// is a no-op. Expands the node if collapsed; moves selection to the first
  /// child if already expanded.
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

  /// Collapses the current node or, if already collapsed or a leaf, selects
  /// its parent.
  ///
  /// Called on ArrowLeft key event. If the current node has children and is
  /// expanded, collapses it. Otherwise navigates upward to the nearest parent
  /// in the tree. No-op if the current node is a root-level node (no parent).
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

  /// Recursively creates [GlobalKey] entries for every node in [nodes].
  ///
  /// Used by [_scrollToNode] to obtain [BuildContext] for scroll-into-view.
  /// Keys are rebuilt on every [loadTree] call, so references are not
  /// preserved across full data reloads.
  void _buildNodeKeys(List<TreeNode> nodes) {
    for (final node in nodes) {
      _nodeKeys[node.id] = GlobalKey();
      if (node.children != null) {
        _buildNodeKeys(node.children!);
      }
    }
  }

  /// Initialises all parent nodes (nodes with children) as expanded.
  ///
  /// Called once by [loadTree] so the full tree is visible by default.
  /// Does not fire [notifyListeners]; subsequent user interaction (toggle,
  /// navigation) may collapse individual nodes.
  void _initExpandedFromTree() {
    for (final node in _treeData) {
      if (node.children != null && node.children!.isNotEmpty) {
        _expanded[node.id] = true;
      }
    }
  }

  /// Expands all ancestor nodes of [targetView] in the tree.
  ///
  /// Called when a view is selected (via tap or keyboard) to ensure the
  /// path to the selected node is visible. If [targetView] is a root node
  /// or already visible, this is a no-op. Fires [notifyListeners] only if a
  /// change was actually made.
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

  /// Returns the flat, depth-first ordered list of nodes that are currently
  /// visible (expanded parents' children are included; collapsed parents'
  /// descendants are excluded).
  ///
  /// Used by arrow-key navigation handlers to determine the next/previous
  /// selectable node. Returns an empty list when the tree is empty.
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

  /// Scrolls the node with [viewId] into the visible viewport using its
  /// [GlobalKey].
  ///
  /// Schedules a post-frame callback to ensure layout is complete before
  /// scrolling. Animated with a 200 ms ease-in-out curve. If the node's
  /// key has no current context (e.g. node is not in the tree or not visible),
  /// the scroll is silently skipped.
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
