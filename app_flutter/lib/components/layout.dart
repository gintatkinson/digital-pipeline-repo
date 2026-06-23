import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/components/breadcrumbs.dart';
import 'package:app_flutter/components/topology_map.dart';

/// TreeNode representing hierarchy selector items
class TreeNode {
  final String id;
  final String label;
  final List<TreeNode>? children;

  const TreeNode({
    required this.id,
    required this.label,
    this.children,
  });
}

const List<TreeNode> defaultTreeData = [
  TreeNode(id: 'Ingestion', label: 'Ingestion'),
  TreeNode(
    id: 'Monitoring',
    label: 'Monitoring',
    children: [
      TreeNode(id: 'Metrics', label: 'Metrics'),
      TreeNode(id: 'Location', label: 'Location'),
      TreeNode(id: 'Chassis', label: 'Chassis'),
    ],
  ),
  TreeNode(
    id: 'Spec',
    label: 'Spec',
    children: [
      TreeNode(id: 'Epics', label: 'Epics'),
      TreeNode(id: 'Traceability', label: 'Traceability'),
    ],
  ),
];

/// The Layout Widget realizes UML::Layout.
class Layout extends StatefulWidget {
  final String? activeView;
  final ValueChanged<String>? onViewChange;
  final Widget? child;
  final String? layoutConfig;
  final String? themeMode;
  final ValueChanged<String>? onThemeModeChange;

  const Layout({
    super.key,
    this.activeView,
    this.onViewChange,
    this.child,
    this.layoutConfig,
    this.themeMode,
    this.onThemeModeChange,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // Navigation & Tree Selection
  late String _currentView;
  final Map<String, bool> _expanded = {
    'Monitoring': true,
    'Spec': true,
  };
  final FocusNode _treeFocusNode = FocusNode();

  // Splitters sizing
  double _sidebarWidth = 240.0;
  double _splitterHeight = 350.0;
  double _topoMapHeight = 200.0;

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
    }
    if (widget.themeMode != null && widget.themeMode != oldWidget.themeMode) {
      setState(() {
        _themeMode = widget.themeMode!;
      });
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _treeFocusNode.dispose();
    _tableVerticalController.dispose();
    _tableHorizontalController.dispose();
    super.dispose();
  }

  Future<void> _loadLayoutConfig() async {
    try {
      String jsonStr;
      if (widget.layoutConfig != null) {
        jsonStr = widget.layoutConfig!;
      } else {
        jsonStr = await DefaultAssetBundle.of(context)
            .loadString('assets/logical-layout.json');
      }
      if (mounted) {
        setState(() {
          _parsedLayout = jsonDecode(jsonStr) as Map<String, dynamic>;
        });
      }
    } catch (e) {
      // Fallback if layout file fails to load or during test contexts
      debugPrint('Error loading layout configuration: $e');
    }
  }

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

    findAndExpandParents(defaultTreeData, targetView, []);
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
    final visible = _getVisibleNodes(defaultTreeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final nextIndex = currentIndex + 1;
    if (nextIndex < visible.length) {
      _selectView(visible[nextIndex].id);
    }
  }

  void _handleArrowUp() {
    final visible = _getVisibleNodes(defaultTreeData);
    final currentIndex = visible.indexWhere((n) => n.id == _currentView);
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      _selectView(visible[prevIndex].id);
    }
  }

  void _handleArrowRight() {
    final visible = _getVisibleNodes(defaultTreeData);
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
    final visible = _getVisibleNodes(defaultTreeData);
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

      final parent = findParent(defaultTreeData, currentNode.id, null);
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
        onClick: () => _selectView('Ingestion'),
      ),
    ];

    if (view == 'Ingestion') {
      return [...base, BreadcrumbItem(id: 'Ingestion', label: 'Ingestion')];
    }
    if (['Metrics', 'Location', 'Chassis'].contains(view)) {
      return [
        ...base,
        BreadcrumbItem(
          id: 'Monitoring',
          label: 'Monitoring',
          onClick: () => _selectView('Metrics'),
        ),
        BreadcrumbItem(id: view, label: view),
      ];
    }
    if (['Epics', 'Traceability'].contains(view)) {
      return [
        ...base,
        BreadcrumbItem(
          id: 'Spec',
          label: 'Spec',
          onClick: () => _selectView('Epics'),
        ),
        BreadcrumbItem(id: view, label: view),
      ];
    }
    return [...base, BreadcrumbItem(id: view, label: view)];
  }

  // Renders the dynamic component tree parsed from logical-layout.json
  Widget _renderComponent(Map<String, dynamic> node, double parentWidth, double parentHeight) {
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
                      .clamp(150.0, math.max(150.0, parentWidth - 300.0));
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
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.blue, Colors.cyan],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.developer_board,
                        color: Colors.white,
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
                      children: defaultTreeData.map(_buildTreeNodeWidget).toList(),
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
                      .clamp(150.0, math.max(150.0, parentHeight - 150.0));
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
        final hasChild = widget.child != null;
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
                            child: widget.child!,
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
        final Map<String, String> labels = {
          'sub_elements_table': 'Items',
          'active_alarms_table': 'Status',
          'historical_events_table': 'Activity',
        };

        final tabs = childrenList.map((c) {
          final id = c['id'] as String;
          final label = labels[id] ?? id;
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
                              color: isSelected ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          t.value.key,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.blue
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
        return _buildTableView(id);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTreeNodeWidget(TreeNode node) {
    final isSelected = _currentView == node.id;
    final isParent = node.children != null && node.children!.isNotEmpty;
    final isExpanded = _expanded[node.id] == true;

    IconData icon;
    if (isParent) {
      icon = isExpanded ? Icons.folder_open : Icons.folder;
    } else {
      switch (node.id) {
        case 'Ingestion':
          icon = Icons.play_arrow;
          break;
        case 'Metrics':
          icon = Icons.bar_chart;
          break;
        case 'Location':
          icon = Icons.location_on;
          break;
        case 'Chassis':
          icon = Icons.dns;
          break;
        case 'Epics':
          icon = Icons.album;
          break;
        case 'Traceability':
          icon = Icons.link;
          break;
        default:
          icon = Icons.insert_drive_file;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: Key('node_${node.id}'),
          onTap: () {
            _selectView(node.id);
            _treeFocusNode.requestFocus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
              border: isSelected
                  ? Border.all(color: Colors.blue.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                if (isParent)
                  InkWell(
                    key: Key('toggle_${node.id}'),
                    onTap: () {
                      setState(() {
                        _expanded[node.id] = !(_expanded[node.id] ?? false);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        isExpanded ? '−' : '+',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 20),
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? Colors.blue
                      : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Colors.blue
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isParent && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: node.children!.map(_buildTreeNodeWidget).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTableView(String tableId) {
    List<String> headers;
    List<List<String>> rows;
    String testId;

    if (tableId == 'sub_elements_table') {
      testId = 'items-table';
      headers = ['ID', 'Name', 'Type', 'Status'];
      rows = [
        ['ITEM-001', 'Ingestion Pipeline', 'Worker', 'Active'],
        ['ITEM-002', 'Telemetry DB', 'Database', 'Idle'],
        ['ITEM-003', 'Web Console', 'Frontend', 'Active'],
      ];
    } else if (tableId == 'active_alarms_table') {
      testId = 'status-table';
      headers = ['Alarm ID', 'Target', 'Severity', 'Timestamp'];
      rows = [
        ['ALARM-101', 'Telemetry DB', 'Critical', '2026-06-23 14:19'],
        ['ALARM-102', 'Ingestion Pipeline', 'Warning', '2026-06-23 14:20'],
      ];
    } else {
      testId = 'activity-table';
      headers = ['Event ID', 'Source', 'Message', 'Timestamp'];
      rows = [
        ['EVENT-201', 'System', 'Console initialized', '2026-06-23 14:19'],
        ['EVENT-202', 'Worker', 'Registered off-thread background worker', '2026-06-23 14:19'],
        ['EVENT-203', 'UI', 'Selected panel reflow isolation scope active', '2026-06-23 14:19'],
      ];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _tableVerticalController,
          notificationPredicate: (notif) => notif.depth == 0,
          child: SingleChildScrollView(
            controller: _tableVerticalController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _tableHorizontalController,
              notificationPredicate: (notif) => notif.depth == 0,
              child: SingleChildScrollView(
                controller: _tableHorizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: DataTable(
                    key: Key(testId),
                    headingRowHeight: 32.0,
                    dataRowMinHeight: 28.0,
                    dataRowMaxHeight: 28.0,
                    horizontalMargin: 12.0,
                    columnSpacing: 24.0,
                    columns: headers
                        .map((h) => DataColumn(
                              label: Text(
                                h,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ))
                        .toList(),
                    rows: rows
                        .map((row) => DataRow(
                              cells: row
                                  .map((cell) => DataCell(
                                        Text(
                                          cell,
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate Theme based on selected mode
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final themeData = ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: const Color(0xFF1A73E8),
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      cardColor: isDark ? const Color(0xFF202124) : const Color(0xFFF1F3F4),
      dividerColor: isDark ? const Color(0xFF3C4043) : const Color(0xFFDADCE0),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A73E8),
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
}
