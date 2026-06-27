import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_flutter/domain/design_tokens.dart';
import 'package:app_flutter/components/property_grid.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/widgets/repository_provider.dart';
import 'package:app_flutter/components/tree_node.dart';
import 'package:app_flutter/services/layout_config_service.dart';
import 'package:app_flutter/services/layout_parser.dart';
import 'package:app_flutter/components/topology_map.dart';
import 'package:app_flutter/services/component_factory.dart';
import 'package:app_flutter/services/properties_service.dart';
import 'package:app_flutter/services/theme_builder.dart';
import 'package:app_flutter/services/background_worker.dart';

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

  // Background Worker
  BackgroundWorker? _worker;

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
    _currentView = widget.activeView ?? _parseTreeHierarchy().first.id;
    _tableVerticalController = ScrollController();
    _tableHorizontalController = ScrollController();

    _loadLayoutConfig();

    _worker = BackgroundWorker()..start();
    _worker!.results.listen((_) {
      if (mounted) setState(() {});
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
    _worker?.dispose();
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
            _updateCurrentViewFromLayout();
          });
        }
      } else {
        final parsed = await loadLayoutConfig('assets/logical-layout.json');
        if (mounted) {
          setState(() {
            _parsedLayout = parsed;
            _updateCurrentViewFromLayout();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading layout configuration: $e');
    }
  }

  void _updateCurrentViewFromLayout() {
    if (widget.activeView == null) {
      final treeData = _parseTreeHierarchy();
      if (treeData.isNotEmpty) {
        _currentView = treeData.first.id;
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
    setState(() {
      _currentView = viewId;
    });
    _propertiesService?.subscribe(viewId);
    if (widget.onViewChange != null) {
      widget.onViewChange!(viewId);
    }
  }

  Widget _buildFromLayout(BuildContext context, BoxConstraints constraints) {
    final factory = ComponentFactory(
      treeData: _treeData,
      currentView: _currentView,
      workerResult: _worker?.lastResult,
      themeMode: _themeMode,
      parsedLayout: _parsedLayout!,
      tableVerticalController: _tableVerticalController,
      tableHorizontalController: _tableHorizontalController,
      onViewSelected: _selectView,
      onThemeModeChange: (val) {
        setState(() => _themeMode = val);
        widget.onThemeModeChange?.call(val);
      },
      minPaneSize: _minPaneSize,
      defaultRatio: _getDefaultRatio,
      resolveTopologyData: _resolveTopologyData,
      resolveTabLabel: _resolveTabLabel,
      buildChildWidget: _buildChildWidget,
    );
    final rootNode = _parsedLayout!['layout']['root_container']
        as Map<String, dynamic>;
    return factory.build(rootNode, constraints.maxWidth, constraints.maxHeight, context);
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
                builder: (context, constraints) =>
                    _buildFromLayout(context, constraints),
              ),
      ),
    );
  }

  Widget _buildChildWidget(BuildContext context) {
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

