import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/features/properties/property_grid.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
import 'package:app_flutter/features/layout/layout_config_service.dart';
import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:app_flutter/features/topology/topology_defaults.dart' show emptyTopologyData, loadTopologyData;
import 'package:app_flutter/features/layout/component_factory.dart';
import 'package:app_flutter/features/properties/view_models/properties_view_model.dart';
import 'package:app_flutter/core/background_worker.dart';

/// The Layout Widget realizes UML::Layout.
class Layout extends StatefulWidget {
  final String? activeView;
  final ValueChanged<String>? onViewChange;
  final String? layoutConfig;

  Layout({
    super.key,
    this.activeView,
    this.onViewChange,
    this.layoutConfig,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // Navigation & Tree Selection
  late String _currentView;

  // Data Source
  DataSource? _dataSource;
  StreamSubscription<Map<String, dynamic>>? _propertiesSubscription;
  Map<String, dynamic> _nodeData = const {};

  // Tree ViewModel
  TreeViewModel? _treeViewModel;

  // Properties ViewModel
  PropertiesViewModel? _propertiesViewModel;

  static const double _minPaneSize = 150.0;

  void _subscribeProperties(String nodeId) {
    _propertiesSubscription?.cancel();
    _nodeData = const {};
    _propertiesSubscription = _dataSource!.watchProperties(nodeId).listen(
      (data) {
        if (mounted) {
          setState(() {
            _nodeData = data;
          });
        }
      },
      onError: (Object error, StackTrace stack) {
        debugPrint('watchProperties error: $error');
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dataSource == null) {
      _dataSource = context.read<DataSource>();
      _subscribeProperties(_currentView);
    }
    if (_treeViewModel == null) {
      final dataSource = context.read<DataSource>();
      _treeViewModel = TreeViewModel(
        dataSource,
        initialView: _currentView,
        onViewSelected: _selectView,
      )
        ..addListener(_onTreeViewModelChanged)
        ..loadTree();
    }
    if (_propertiesViewModel == null) {
      final dataSource = context.read<DataSource>();
      _propertiesViewModel = PropertiesViewModel(dataSource)
        ..addListener(_onPropertiesViewModelChanged)
        ..loadType(_currentView);
    }
  }

  void _onPropertiesViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onTreeViewModelChanged() {
    if (mounted) {
      _updateCurrentViewFromLayout();
      setState(() {});
    }
  }

  // Background Worker
  BackgroundWorker? _worker;
  StreamSubscription<int>? _workerSubscription;

  // Parsed configuration map
  Map<String, dynamic>? _parsedLayout;

  // Cached JSON files
  Map<String, dynamic>? _cachedRules;
  Map<String, dynamic>? _cachedLabels;

  Map<String, dynamic> _loadJsonOnce(String path) {
    if (_cachedRules != null && path.contains('codebase_rules')) return _cachedRules!;
    if (_cachedLabels != null && path.contains('labels')) return _cachedLabels!;
    try {
      for (final candidate in [path, '../$path']) {
        final file = File(candidate);
        if (file.existsSync()) {
          final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
          if (path.contains('codebase_rules')) _cachedRules = data;
          if (path.contains('labels')) _cachedLabels = data;
          return data;
        }
      }
    } catch (_) {}
    return {};
  }

  // Properties Reactive State

  // Preloaded topology data from external JSON asset.
  TopologyData? _topologyData;

  @override
  void initState() {
    super.initState();

    if (widget.layoutConfig != null) {
      _parsedLayout = jsonDecode(widget.layoutConfig!) as Map<String, dynamic>;
    } else {
      _loadLayoutConfig();
    }

    _currentView = widget.activeView ?? 'root';

    _worker = BackgroundWorker()..start();
    _workerSubscription = _worker!.results.listen((_) {
      if (mounted) setState(() {});
    });

    _preloadTopologyData();
  }

  Future<void> _preloadTopologyData() async {
    try {
      final data = await loadTopologyData();
      if (mounted) {
        setState(() {
          _topologyData = data;
        });
      }
    } catch (e) {
      debugPrint('Error loading topology data: $e');
    }
  }

  @override
  void didUpdateWidget(covariant Layout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeView != null && widget.activeView != oldWidget.activeView) {
      if (_currentView != widget.activeView) {
        setState(() {
          _currentView = widget.activeView!;
        });
        _subscribeProperties(_currentView);
        _propertiesViewModel?.loadType(_currentView);
      }
    }
  }

  @override
  void dispose() {
    _propertiesSubscription?.cancel();
    _workerSubscription?.cancel();
    _worker?.dispose();
    _treeViewModel?.removeListener(_onTreeViewModelChanged);
    _treeViewModel?.dispose();
    _propertiesViewModel?.removeListener(_onPropertiesViewModelChanged);
    _propertiesViewModel?.dispose();
    super.dispose();
  }

  double _getDefaultRatio() {
    final rules = _loadJsonOnce('.pipeline/logical-ui/codebase_rules.json');
    return getDefaultRatio(rules, 'layout_properties.default_ratio', 0.5);
  }

  Map<String, String> _resolveCoordinateMapping() {
    final rules = _loadJsonOnce('.pipeline/logical-ui/codebase_rules.json');
    return resolveCoordinateMapping(rules);
  }

  Map<String, String> _resolveLabelsMapping() {
    final rules = _loadJsonOnce('.pipeline/logical-ui/codebase_rules.json');
    return resolveLabelsMapping(rules);
  }

  String _resolveTabLabel(String tabId) {
    final mapping = _resolveLabelsMapping();
    for (final entry in mapping.entries) {
      if (tabId.contains(entry.key)) {
        return entry.value;
      }
    }
    // TODO(#79): Replace hardcoded tab label fallbacks with config-driven mapping.
    if (tabId == 'sub_elements_table') return 'Items';
    if (tabId == 'active_alarms_table') return 'Status';
    if (tabId == 'historical_events_table') return 'Activity';
    return tabId;
  }

  // TODO(#79): Replace mock topology nodes/links with DB-backed data.
  TopologyData _resolveTopologyData() {
    final mapping = _resolveCoordinateMapping();
    final data = _topologyData ?? emptyTopologyData;
    return TopologyData(
      coordinateMapping: mapping,
      nodes: data.nodes,
      links: data.links,
    );
  }


  Future<void> _loadLayoutConfig() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/logical-layout.json');
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _parsedLayout = parsed;
          _updateCurrentViewFromLayout();
        });
      }
    } catch (e) {
      debugPrint('Error loading layout configuration: $e');
    }
  }

  void _updateCurrentViewFromLayout() {
    debugPrint('[LAYOUT] _updateCurrentViewFromLayout: activeView=${widget.activeView}');
    if (widget.activeView == null && _treeViewModel != null && _treeViewModel!.treeData.isNotEmpty) {
      _currentView = _treeViewModel!.treeData.first.id;
      debugPrint('[LAYOUT] _updateCurrentViewFromLayout: setting _currentView=$_currentView');
      _subscribeProperties(_currentView);
      _propertiesViewModel?.loadType(_currentView);
    }
  }

  void _selectView(String viewId) {
    debugPrint('[LAYOUT] _selectView: viewId=$viewId, _currentView=$_currentView');
    if (_currentView == viewId) return;
    setState(() {
      _currentView = viewId;
    });
    _treeViewModel?.updateCurrentView(viewId);
    _subscribeProperties(viewId);
    _propertiesViewModel?.loadType(viewId);
    widget.onViewChange?.call(viewId);
  }

  Widget _buildFromLayout(BuildContext context, BoxConstraints constraints) {
    final treeData = _treeViewModel?.treeData ?? [];
    final factory = ComponentFactory(
      currentView: _currentView,
      workerResult: _worker?.lastResult,
      parsedLayout: _parsedLayout!,
      onViewSelected: _selectView,
      minPaneSize: _minPaneSize,
      defaultRatio: _getDefaultRatio,
      resolveTopologyData: _resolveTopologyData,
      resolveTabLabel: _resolveTabLabel,
      buildChildWidget: _buildChildWidget,
      treeViewModel: _treeViewModel,
    );
    final rootNode = _parsedLayout!['layout']['root_container']
        as Map<String, dynamic>;
    return factory.build(rootNode, constraints.maxWidth, constraints.maxHeight, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _parsedLayout == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) =>
                  _buildFromLayout(context, constraints),
            ),
    );
  }

  Widget _buildChildWidget(BuildContext context) {
    final fields = _propertiesViewModel?.fields ?? [];

    return PropertyGrid(
      activeView: _currentView,
      fields: fields,
      initialValues: _nodeData,
      onSave: (Map<String, dynamic> data) async {
        await _dataSource!.saveProperties(_currentView, data);
      },
    );
  }
}
