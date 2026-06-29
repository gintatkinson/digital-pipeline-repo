import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/features/properties/property_grid.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/features/tree/tree_node.dart';
import 'package:app_flutter/features/tree/view_models/tree_view_model.dart';
import 'package:app_flutter/features/layout/layout_config_service.dart';
import 'package:app_flutter/features/layout/layout_parser.dart';
import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:app_flutter/features/topology/topology_defaults.dart';
import 'package:app_flutter/features/tree/tree_defaults.dart';
import 'package:app_flutter/features/layout/component_factory.dart';
import 'package:app_flutter/features/properties/properties_service.dart';
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

  // Services
  PropertiesService? _propertiesService;

  // Tree ViewModel
  TreeViewModel? _treeViewModel;

  static const double _minPaneSize = 150.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_propertiesService == null) {
      final repo = context.read<AbstractRepository>();
      _propertiesService = PropertiesService(repo)
        ..addListener(_onPropertiesChanged)
        ..subscribe(_currentView);
    }
  }

  void _onPropertiesChanged() {
    if (mounted) setState(() {});
  }

  // Background Worker
  BackgroundWorker? _worker;

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

  // Properties Reactive State - handled by PropertiesService

  @override
  void initState() {
    super.initState();
    _currentView = widget.activeView ?? _parseTreeHierarchy().first.id;

    _treeViewModel = TreeViewModel(
      treeData: _treeData,
      initialView: _currentView,
      onViewSelected: _selectView,
    );

    if (widget.layoutConfig != null) {
      _parsedLayout = jsonDecode(widget.layoutConfig!) as Map<String, dynamic>;
      _updateCurrentViewFromLayout();
    } else {
      _loadLayoutConfig();
    }

    _worker = BackgroundWorker()..start();
    _worker!.results.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant Layout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeView != null && widget.activeView != oldWidget.activeView) {
      if (_currentView != widget.activeView) {
        setState(() {
          _currentView = widget.activeView!;
        });
        _propertiesService?.subscribe(_currentView);
      }
    }
  }

  @override
  void dispose() {
    _propertiesService?.dispose();
    _worker?.dispose();
    _treeViewModel?.dispose();
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
    return TopologyData(
      coordinateMapping: mapping,
      nodes: defaultTopologyData.nodes,
      links: defaultTopologyData.links,
    );
  }


  Future<void> _loadLayoutConfig() async {
    try {
      final parsed = await loadLayoutConfig('assets/logical-layout.json');
      if (mounted) {
        setState(() {
          _parsedLayout = parsed;
          _updateCurrentViewFromLayout();
          _treeViewModel?.dispose();
          _treeViewModel = TreeViewModel(
            treeData: _treeData,
            initialView: _currentView,
            onViewSelected: _selectView,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading layout configuration: $e');
    }
  }

  void _updateCurrentViewFromLayout() {
    debugPrint('[LAYOUT] _updateCurrentViewFromLayout: activeView=${widget.activeView}');
    if (widget.activeView == null) {
      final treeData = _parseTreeHierarchy();
      debugPrint('[LAYOUT] _updateCurrentViewFromLayout: treeData=${treeData.map((n) => n.id).toList()}');
      if (treeData.isNotEmpty) {
        _currentView = treeData.first.id;
        debugPrint('[LAYOUT] _updateCurrentViewFromLayout: setting _currentView=$_currentView');
        _propertiesService?.subscribe(_currentView);
      }
    }
  }

  List<TreeNode> _parseTreeHierarchy() {
    if (_parsedLayout == null) {
      return defaultTreeData;
    }
    return parseTreeHierarchy(_parsedLayout!);
  }

  List<TreeNode> get _treeData => _parseTreeHierarchy();

  void _selectView(String viewId) {
    debugPrint('[LAYOUT] _selectView: viewId=$viewId, _currentView=$_currentView');
    if (_currentView == viewId) return;
    setState(() {
      _currentView = viewId;
    });
    _treeViewModel?.updateCurrentView(viewId);
    _propertiesService?.subscribe(viewId);
    widget.onViewChange?.call(viewId);
  }

  Widget _buildFromLayout(BuildContext context, BoxConstraints constraints) {
    final factory = ComponentFactory(
      treeData: _treeData,
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
    final nodeData = _propertiesService?.lastData ?? const {};

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
      initialValues: nodeData,
      onSave: (Map<String, dynamic> data) async {
        final resolvedRepo = context.read<AbstractRepository>();
        await resolvedRepo.saveProperties(_currentView, data);
      },
    );
  }
}
