import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:app_flutter/components/topology_map.dart';
import 'package:app_flutter/domain/design_tokens.dart';
import 'package:app_flutter/components/property_grid.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/widgets/repository_provider.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/components/table_view_config.dart';
import 'package:app_flutter/components/table_view_widget.dart';
import 'package:app_flutter/services/layout_config_service.dart';
import 'package:app_flutter/services/layout_parser.dart';
import 'package:app_flutter/components/sidebar_tree.dart';
import 'package:app_flutter/components/split_workspace.dart';
import 'package:app_flutter/components/tabbed_container.dart';
import 'package:app_flutter/components/topographical_view.dart';
import 'package:app_flutter/services/properties_service.dart';
import 'package:app_flutter/services/theme_builder.dart';

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
  // Navigation & Tree Selection
  late String _currentView;

  // Services
  PropertiesService? _propertiesService;

  // Splitters sizing

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
    if (_propertiesService == null) {
      final repo = RepositoryProvider.of(context);
      _propertiesService = PropertiesService(repo)
        ..addListener(_onPropertiesChanged)
        ..subscribe(_currentView);
    }
  }

  void _onPropertiesChanged() {
    if (mounted) setState(() {});
  }

  // Background Worker Simulation
  int? _workerResult;
  Timer? _periodicTimer;
  int _timerCounter = 0;

  // Theme state
  late String _themeMode;



  // Table Scroll Controllers
  late final ScrollController _tableVerticalController;
  late final ScrollController _tableHorizontalController;

  // Parsed configuration map
  Map<String, dynamic>? _parsedLayout;

  // Properties Reactive State - handled by PropertiesService

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode ?? 'system';
    _currentView = widget.activeView ?? 'Ingestion';
    _tableVerticalController = ScrollController();
    _tableHorizontalController = ScrollController();

    _loadLayoutConfig();

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
      _propertiesService?.subscribe(_currentView);
    }
    if (widget.themeMode != null && widget.themeMode != oldWidget.themeMode) {
      setState(() {
        _themeMode = widget.themeMode!;
      });
    }
  }

  @override
  void dispose() {
    _propertiesService?.dispose();
    _periodicTimer?.cancel();
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
        }
      } else {
        final parsed = await loadLayoutConfig('assets/logical-layout.json');
        if (mounted) {
          setState(() {
            _parsedLayout = parsed;
          });
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

  void _selectView(String viewId) {
    setState(() {
      _currentView = viewId;
    });
    _propertiesService?.subscribe(viewId);
    if (widget.onViewChange != null) {
      widget.onViewChange!(viewId);
    }
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

        return SplitWorkspace(
          leading: sidebarChild != null
              ? _renderComponent(sidebarChild as Map<String, dynamic>, parentWidth, parentHeight)
              : const SizedBox.shrink(),
          trailing: splitWorkspaceChild != null
              ? _renderComponent(splitWorkspaceChild as Map<String, dynamic>, parentWidth, parentHeight)
              : const SizedBox.shrink(),
          direction: Axis.horizontal,
          minFirstPaneSize: _minPaneSize,
          initialRatio: 0.25,
          splitterKey: const Key('vertical_splitter'),
        );

      case 'HierarchyTreeSelector':
        return SidebarTree(
          treeData: _treeData,
          currentView: _currentView,
          workerResult: _workerResult,
          themeMode: _themeMode,
          onViewSelected: _selectView,
          onThemeModeChange: (val) {
            setState(() {
              _themeMode = val;
            });
            if (widget.onThemeModeChange != null) {
              widget.onThemeModeChange!(val);
            }
          },
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

        return SplitWorkspace(
          leading: topoChild != null
              ? _renderComponent(topoChild as Map<String, dynamic>, parentWidth, parentHeight)
              : const SizedBox.shrink(),
          trailing: tabbedChild != null
              ? _renderComponent(tabbedChild as Map<String, dynamic>, parentWidth, parentHeight)
              : const SizedBox.shrink(),
          direction: Axis.vertical,
          minFirstPaneSize: _minPaneSize,
          initialRatio: _getDefaultRatio(),
          splitterKey: const Key('horizontal_splitter'),
          onDrag: _runWorkerCalculation,
        );

      case 'TopographicalView':
        return TopographicalView(
          currentView: _currentView,
          parsedLayout: _parsedLayout!,
          onViewSelected: _selectView,
          child: _buildChildWidget(),
          topologyData: _resolveTopologyData(),
        );

      case 'TabbedContainer':
        final childrenList = node['children'] as List<dynamic>? ?? [];

        final tabs = childrenList.map((c) {
          final id = c['id'] as String;
          final label = _resolveTabLabel(id);
          return TabConfig(
            id: id,
            label: label,
            contentBuilder: (_) => _renderComponent(c as Map<String, dynamic>, parentWidth, parentHeight),
          );
        }).toList();

        return TabbedContainer(
          tabs: tabs,
          initialTabId: tabs.isNotEmpty ? tabs.first.id : '',
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
    final isDark = _themeMode == 'dark' ||
        (_themeMode == 'system' &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final themeData = buildThemeFromTokens(registry, isDark);

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
      initialValues: _propertiesService?.currentNodeData ?? {},
      onSave: (String key, dynamic value) async {
        final resolvedRepo = RepositoryProvider.of(context);
        final updatedData = Map<String, dynamic>.from(_propertiesService?.currentNodeData ?? {});
        updatedData[key] = value;
        await resolvedRepo.saveProperties(_currentView, updatedData);
      },
    );
  }
}

