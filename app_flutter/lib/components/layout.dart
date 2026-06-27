import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/components/breadcrumbs.dart';
import 'package:app_flutter/components/topology_map.dart';
import 'package:app_flutter/domain/design_tokens.dart';
import 'package:app_flutter/components/property_grid.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/widgets/repository_provider.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/components/tree_node_widget.dart';
import 'package:app_flutter/components/table_view_config.dart';
import 'package:app_flutter/components/table_view_widget.dart';
import 'package:app_flutter/services/layout_config_service.dart';
import 'package:app_flutter/services/layout_parser.dart';

/// The Layout Widget realizes UML::Layout.
class Layout extends StatefulWidget {
  final String? activeView;
  final ValueChanged<String>? onViewChange;
  final String? layoutConfig;
  final String? themeMode;
  final ValueChanged<String>? onThemeModeChange;

  Layout({
    super.key,
    this.activeView,
    this.onViewChange,
    this.layoutConfig,
    this.themeMode,
    this.onThemeModeChange,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  bool _didInitProperties = false;

  // Navigation & Tree Selection
  late String _currentView;
  final Map<String, bool> _expanded = {
    'Monitoring': true,
    'Spec': true,
  };
  final FocusNode _treeFocusNode = FocusNode();

  // Splitters sizing
  double _sidebarWidth = 240.0;
  bool _sidebarWidthInitialized = false;
  double _splitterHeight = 350.0;
  double _topoMapHeight = 200.0;
  bool _splitterInitialized = false;

  double get _minPaneSize {
    try {
      return DesignTokenProvider.of(context).getDimension('component.splitter.min-pane-size');
    } catch (_) {
      return 150.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sidebarWidthInitialized) {
      try {
        final registry = DesignTokenProvider.of(context);
        _sidebarWidth = registry.getDimension('component.sidebar.width');
      } catch (_) {
        _sidebarWidth = 280.0;
      }
      _sidebarWidthInitialized = true;
    }
    if (!_didInitProperties) {
      _didInitProperties = true;
      _subscribeToProperties(_currentView);
    }
  }

  // Background Worker Simulation
  int? _workerResult;
  Timer? _periodicTimer;
  int _timerCounter = 0;

  // Theme state
  late String _themeMode;

  // TabbedContainer state
  String _activeTabId = 'sub_elements_table';

  // Table Scroll Controllers
  late final ScrollController _tableVerticalController;
  late final ScrollController _tableHorizontalController;

  // Parsed configuration map
  Map<String, dynamic>? _parsedLayout;

  // Properties Reactive State
  Map<String, dynamic>? _currentNodeData;
  StreamSubscription<Map<String, dynamic>>? _propertiesSubscription;

  void _subscribeToProperties(String nodeId) {
    _propertiesSubscription?.cancel();
    final resolvedRepo = RepositoryProvider.of(context);
    _propertiesSubscription = resolvedRepo.watchProperties(nodeId).listen((data) {
      if (mounted) {
        setState(() {
          _currentNodeData = data;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode ?? 'system';
    _currentView = widget.activeView ?? 'Ingestion';
    _tableVerticalController = ScrollController();
    _tableHorizontalController = ScrollController();

    _loadLayoutConfig();
    _expandParents(_currentView);

    // Initialize simulated periodic off-thread background worker
    _periodicTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _timerCounter++;
      _runWorkerCalculation(_timerCounter.toDouble());
    });
  }

  @override
  void didUpdateWidget(covariant Layout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeView != null && widget.activeView != oldWidget.activeView) {
      setState(() {
        _currentView = widget.activeView!;
      });
      _expandParents(_currentView);
      _subscribeToProperties(_currentView);
    }
    if (widget.themeMode != null && widget.themeMode != oldWidget.themeMode) {
      setState(() {
        _themeMode = widget.themeMode!;
      });
    }
  }

  @override
  void dispose() {
    _propertiesSubscription?.cancel();
    _periodicTimer?.cancel();
    _treeFocusNode.dispose();
    _tableVerticalController.dispose();
    _tableHorizontalController.dispose();
    super.dispose();
  }

  double _getDefaultRatio() {
    try {
      for (final path in ['../.pipeline/logical-ui/codebase_rules.json', '.pipeline/logical-ui/codebase_rules.json']) {
        final file = File(path);
        if (file.existsSync()) {
          final rules = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          return getDefaultRatio(rules, 'layout_properties.default_ratio', 0.5);
        }
      }
    } catch (_) {}
    return 0.5;
  }

  Map<String, String> _resolveCoordinateMapping() {
    try {
      Map<String, dynamic>? rules;
      final file1 = File('../.pipeline/logical-ui/codebase_rules.json');
      if (file1.existsSync()) {
        rules = jsonDecode(file1.readAsStringSync()) as Map<String, dynamic>?;
      } else {
        final file2 = File('.pipeline/logical-ui/codebase_rules.json');
        if (file2.existsSync()) {
          rules = jsonDecode(file2.readAsStringSync()) as Map<String, dynamic>?;
        }
      }
      return resolveCoordinateMapping(rules ?? <String, dynamic>{});
    } catch (_) {
      return resolveCoordinateMapping(<String, dynamic>{});
    }
  }

  Map<String, String> _resolveLabelsMapping() {
    try {
      Map<String, dynamic>? rules;
      final file1 = File('../.pipeline/logical-ui/codebase_rules.json');
      if (file1.existsSync()) {
        rules = jsonDecode(file1.readAsStringSync()) as Map<String, dynamic>?;
      } else {
        final file2 = File('.pipeline/logical-ui/codebase_rules.json');
        if (file2.existsSync()) {
          rules = jsonDecode(file2.readAsStringSync()) as Map<String, dynamic>?;
        }
      }
      return resolveLabelsMapping(rules ?? <String, dynamic>{});
    } catch (_) {
      return resolveLabelsMapping(<String, dynamic>{});
    }
  }

  String _resolveTabLabel(String tabId) {
    final mapping = _resolveLabelsMapping();
    for (final entry in mapping.entries) {
      if (tabId.contains(entry.key)) {
        return entry.value;
      }
    }
    if (tabId == 'sub_elements_table') return 'Items';
    if (tabId == 'active_alarms_table') return 'Status';
    if (tabId == 'historical_events_table') return 'Activity';
    return tabId;
  }

  TopologyData _resolveTopologyData() {
    final mapping = _resolveCoordinateMapping();
    return TopologyData(
      coordinateMapping: mapping,
      nodes: defaultTopologyData.nodes,
      links: defaultTopologyData.links,
    );
  }


  Future<void> _loadLayoutConfig() async {
    try {
      String jsonStr;
      if (widget.layoutConfig != null) {
        jsonStr = widget.layoutConfig!;
        final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _parsedLayout = parsed;
          });
          _expandParents(_currentView);
        }
      } else {
        final parsed = await loadLayoutConfig('assets/logical-layout.json');
        if (mounted) {
          setState(() {
            _parsedLayout = parsed;
          });
          _expandParents(_currentView);
        }
      }
    } catch (e) {
      debugPrint('Error loading layout configuration: $e');
    }
  }

  List<TreeNode> _parseTreeHierarchy() {
    if (_parsedLayout == null) {
      return defaultTreeData;
    }
    return parseTreeHierarchy(_parsedLayout!);
  }

  List<TreeNode> get _treeData => _parseTreeHierarchy();

  // Runs off-thread calculations to simulate background worker
  void _runWorkerCalculation(double value) async {
    try {
      final result = await Isolate.run(() {
        double sum = 0.0;
        for (int i = 0; i < 1000000; i++) {
          sum += math.sin(value + i);
        }
        return sum.round();
      });
      if (mounted) {
        setState(() {
          _workerResult = result;
        });
      }
    } catch (e) {
      // Fallback calculation on current thread if Isolate.run fails
      double sum = 0.0;
      for (int i = 0; i < 1000000; i++) {
        sum += math.sin(value + i);
      }
      if (mounted) {
        setState(() {
          _workerResult = sum.round();
        });
      }
    }
  }

  // Expand parent hierarchy programmatically when activeView / currentView changes
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
    final visible = _getVisibleNodes(_treeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      _selectView(visible[nextIndex].id);
    }
  }

  void _handleArrowUp() {
    final visible = _getVisibleNodes(_treeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      _selectView(visible[prevIndex].id);
    }
  }

  void _handleArrowRight() {
    final visible = _getVisibleNodes(_treeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
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
    final visible = _getVisibleNodes(_treeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
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

      final parent = findParent(_treeData, currentNode.id, null);
      if (parent != null) {
        _selectView(parent.id);
      }
    }
  }

  void _selectView(String viewId) {
    setState(() {
      _currentView = viewId;
    });
    _expandParents(viewId);
    _subscribeToProperties(viewId);
    if (widget.onViewChange != null) {
      widget.onViewChange!(viewId);
    }
  }

  // Get Breadcrumbs path items dynamically based on selection
  List<BreadcrumbItem> _getBreadcrumbsItems(String view) {
    final List<BreadcrumbItem> base = [
      BreadcrumbItem(
        id: 'home',
        label: 'Antigravity Console',
        onClick: () {
          if (_treeData.isNotEmpty) {
            String getFirstLeafId(TreeNode node) {
              if (node.children == null || node.children!.isEmpty) {
                return node.id;
              }
              return getFirstLeafId(node.children!.first);
            }
            _selectView(getFirstLeafId(_treeData.first));
          } else {
            _selectView('Ingestion');
          }
        },
      ),
    ];

    List<TreeNode>? findPath(List<TreeNode> nodes, String targetId, List<TreeNode> currentPath) {
      for (final node in nodes) {
        if (node.id == targetId) {
          return [...currentPath, node];
        }
        if (node.children != null) {
          final found = findPath(node.children!, targetId, [...currentPath, node]);
          if (found != null) return found;
        }
      }
      return null;
    }

    final path = findPath(_treeData, view, []);
    if (path == null || path.isEmpty) {
      return [...base, BreadcrumbItem(id: view, label: view)];
    }

    final List<BreadcrumbItem> items = [...base];
    for (int i = 0; i < path.length; i++) {
      final node = path[i];
      if (i == path.length - 1) {
        items.add(BreadcrumbItem(id: node.id, label: node.label));
      } else {
        String getFirstLeafId(TreeNode n) {
          if (n.children == null || n.children!.isEmpty) {
            return n.id;
          }
          return getFirstLeafId(n.children!.first);
        }
        items.add(
          BreadcrumbItem(
            id: node.id,
            label: node.label,
            onClick: () => _selectView(getFirstLeafId(node)),
          ),
        );
      }
    }
    return items;
  }

  // Renders the dynamic component tree parsed from logical-layout.json
  Widget _renderComponent(Map<String, dynamic> node, double parentWidth, double parentHeight) {
    final registry = DesignTokenProvider.of(context);
    final brandPrimary = registry.getColor('alias.color.brand-primary');
    final whiteColor = registry.getColor('global.color.white');

    final type = node['type'] as String?;
    switch (type) {
      case 'SidebarLayout':
        final childrenList = node['children'] as List<dynamic>? ?? [];
        final sidebarChild = childrenList.firstWhere(
          (c) => c['type'] == 'HierarchyTreeSelector',
          orElse: () => null,
        );
        final splitWorkspaceChild = childrenList.firstWhere(
          (c) => c['type'] == 'SplitWorkspace',
          orElse: () => null,
        );

        return Row(
          children: [
            if (sidebarChild != null)
              SizedBox(
                width: _sidebarWidth,
                child: _renderComponent(sidebarChild as Map<String, dynamic>, parentWidth, parentHeight),
              ),
            // Vertical splitter bar
            GestureDetector(
              key: const Key('vertical_splitter'),
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _sidebarWidth = (_sidebarWidth + details.delta.dx)
                      .clamp(_minPaneSize, math.max(_minPaneSize, parentWidth - 300.0));
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.grey.shade200,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 40,
                      color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3) ??
                          Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            if (splitWorkspaceChild != null)
              Expanded(
                child: _renderComponent(splitWorkspaceChild as Map<String, dynamic>, parentWidth, parentHeight),
              ),
          ],
        );

      case 'HierarchyTreeSelector':
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
                      children: _treeData.map((node) => TreeNodeWidget(
                        node: node,
                        expanded: _expanded,
                        focusNode: _treeFocusNode,
                        currentView: _currentView,
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
                            'Worker: ${_workerResult ?? "Idle"}',
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
                              value: _themeMode,
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
                                  setState(() {
                                    _themeMode = val;
                                  });
                                  if (widget.onThemeModeChange != null) {
                                    widget.onThemeModeChange!(val);
                                  }
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

      case 'SplitWorkspace':
        final childrenList = node['children'] as List<dynamic>? ?? [];
        final topoChild = childrenList.firstWhere(
          (c) => c['type'] == 'TopographicalView',
          orElse: () => null,
        );
        final tabbedChild = childrenList.firstWhere(
          (c) => c['type'] == 'TabbedContainer',
          orElse: () => null,
        );

        if (!_splitterInitialized && parentHeight > 0) {
          final ratio = _getDefaultRatio();
          _splitterHeight = parentHeight * ratio;
          _splitterInitialized = true;
        }

        return Column(
          children: [
            if (topoChild != null)
              SizedBox(
                height: _splitterHeight,
                child: _renderComponent(topoChild as Map<String, dynamic>, parentWidth, parentHeight),
              ),
            // Horizontal SplitWorkspace splitter
            GestureDetector(
              key: const Key('horizontal_splitter'),
              onVerticalDragUpdate: (details) {
                setState(() {
                  _splitterHeight = (_splitterHeight + details.delta.dy)
                      .clamp(_minPaneSize, math.max(_minPaneSize, parentHeight - _minPaneSize));
                });
                _runWorkerCalculation(_splitterHeight);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.grey.shade200,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 2,
                      color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3) ??
                          Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            if (tabbedChild != null)
              Expanded(
                child: _renderComponent(tabbedChild as Map<String, dynamic>, parentWidth, parentHeight),
              ),
          ],
        );

      case 'TopographicalView':
        const hasChild = true;
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active View Title & Breadcrumbs Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active View: $_currentView',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: NavigationBreadcrumbs(
                          items: _getBreadcrumbsItems(_currentView),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body area with Topology map and optional PropertyGrid child
              Expanded(
                child: LayoutBuilder(
                  builder: (context, topoBox) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Map viewport
                        SizedBox(
                          height: hasChild ? _topoMapHeight : topoBox.maxHeight,
                          child: TopologyMap(
                            activeFocusedNode: _currentView,
                            onNodeSelect: (nodeId) {
                              _selectView(nodeId);
                            },
                            data: _resolveTopologyData(),
                          ),
                        ),
                        // Splitter if child exists
                        if (hasChild) ...[
                          GestureDetector(
                            key: const Key('topo_splitter'),
                            onVerticalDragUpdate: (details) {
                              setState(() {
                                _topoMapHeight = (_topoMapHeight + details.delta.dy)
                                    .clamp(100.0, math.max(100.0, parentHeight - 100.0));
                              });
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black26
                                      : Colors.grey.shade200,
                                  border: Border(
                                    top: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                    bottom: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 2,
                                    color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3) ??
                                        Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildChildWidget(),
                          ),
                        ]
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case 'TabbedContainer':
        final childrenList = node['children'] as List<dynamic>? ?? [];

        final tabs = childrenList.map((c) {
          final id = c['id'] as String;
          final label = _resolveTabLabel(id);
          return MapEntry(id, MapEntry(label, c));
        }).toList();

        final activeTabEntry = tabs.firstWhere(
          (t) => t.key == _activeTabId,
          orElse: () => tabs.isNotEmpty ? tabs.first : MapEntry('', MapEntry('', null)),
        );

        return Container(
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab Selector Row
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  children: tabs.map((t) {
                    final isSelected = t.key == _activeTabId;
                    return InkWell(
                      key: Key('tab_btn_${t.key}'),
                      onTap: () {
                        setState(() {
                          _activeTabId = t.key;
                        });
                      },
                       child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? brandPrimary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          t.value.key,
                          style: TextStyle(
                            color: isSelected
                                ? brandPrimary
                                : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Tab content
              Expanded(
                child: activeTabEntry.value.value != null
                    ? _renderComponent(
                        activeTabEntry.value.value as Map<String, dynamic>,
                        parentWidth,
                        parentHeight,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );

      case 'TableView':
        final id = node['id'] as String? ?? '';
        return TableViewWidget(
          tabId: id,
          parsedLayout: _parsedLayout!,
          tableViewRegistry: tableViewRegistry,
          verticalController: _tableVerticalController,
          horizontalController: _tableHorizontalController,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registry = DesignTokenProvider.of(context);
    // Generate Theme based on selected mode
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final theme = isDark ? 'dark' : 'light';
    final primary = registry.getColor('alias.color.brand-primary', theme: theme);
    final bg = registry.getColor('alias.color.background', theme: theme);
    final surface = registry.getColor('alias.color.surface', theme: theme);
    final divider = registry.getColor(isDark ? 'global.color.gray-900' : 'global.color.gray-100');

    final themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      dividerColor: divider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    return Theme(
      data: themeData,
      child: Scaffold(
        body: _parsedLayout == null
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final parentWidth = constraints.maxWidth;
                  final parentHeight = constraints.maxHeight;

                  final rootNode = _parsedLayout!['layout']['root_container']
                      as Map<String, dynamic>;
                  return _renderComponent(rootNode, parentWidth, parentHeight);
                },
              ),
      ),
    );
  }

  Widget _buildChildWidget() {
    List<AttributeDefinition>? dynamicAttributes;
    if (_parsedLayout != null && _parsedLayout!['attributes'] != null) {
      try {
        final list = _parsedLayout!['attributes'] as List<dynamic>;
        dynamicAttributes = list
            .map((e) => AttributeDefinition.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error parsing dynamic attributes: $e');
      }
    }

    return PropertyGrid(
      activeView: _currentView,
      attributes: dynamicAttributes,
      initialValues: _currentNodeData ?? {},
      onSave: (String key, dynamic value) async {
        final resolvedRepo = RepositoryProvider.of(context);
        final updatedData = Map<String, dynamic>.from(_currentNodeData ?? {});
        updatedData[key] = value;
        await resolvedRepo.saveProperties(_currentView, updatedData);
      },
    );
  }
}

