import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_flutter/core/design_tokens.dart';
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
import 'package:app_flutter/core/theme_builder.dart';
import 'package:app_flutter/core/background_worker.dart';

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

  // Tree ViewModel
  TreeViewModel? _treeViewModel;

  // Splitters sizing
  double _getMinPaneSize(DesignTokenRegistry registry) {
    try {
      return registry.getDimension('component.splitter.min-pane-size');
    } catch (_) {
      return 150.0;
    }
  }

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

  // Theme state
  late String _themeMode;



  // Parsed configuration map
  Map<String, dynamic>? _parsedLayout;

  // Properties Reactive State - handled by PropertiesService

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode ?? 'system';
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
    if (widget.themeMode != null && widget.themeMode != oldWidget.themeMode) {
      setState(() {
        _themeMode = widget.themeMode!;
      });
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

  Widget _buildFromLayout(BuildContext context, BoxConstraints constraints, DesignTokenRegistry registry) {
    final factory = ComponentFactory(
      treeData: _treeData,
      currentView: _currentView,
      workerResult: _worker?.lastResult,
      themeMode: _themeMode,
      parsedLayout: _parsedLayout!,
      onViewSelected: _selectView,
      onThemeModeChange: (val) {
        setState(() => _themeMode = val);
        widget.onThemeModeChange?.call(val);
      },
      minPaneSize: _getMinPaneSize(registry),
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
    final registry = context.watch<DesignTokenRegistry>();
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
                builder: (context, constraints) =>
                    _buildFromLayout(context, constraints, registry),
              ),
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
      onSave: (String key, dynamic value) async {
        final resolvedRepo = context.read<AbstractRepository>();
        final currentData = _propertiesService?.currentNodeData;
        if (currentData == null) return;
        final updatedData = Map<String, dynamic>.from(currentData);
        updatedData[key] = value;
        await resolvedRepo.saveProperties(_currentView, updatedData);
      },
    );
  }
}
