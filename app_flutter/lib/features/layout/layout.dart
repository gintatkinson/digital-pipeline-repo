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
import 'package:app_flutter/features/properties/action_panel.dart';
import 'package:app_flutter/features/properties/state_indicator.dart';
import 'package:app_flutter/domain/action_descriptor.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Root layout widget that parses a logical-layout JSON and builds the full
/// Flutter widget hierarchy (sidebar, split panes, topology, tabs, property
/// grid).
///
/// Realises UML::Layout. Initialises [TreeViewModel], [PropertiesViewModel],
/// a [BackgroundWorker], and topology data on first build. Coordinates view
/// selection across all child components: when a view is selected,
/// [_selectView] updates the current view, subscribes to properties, and
/// notifies the tree view model.
///
/// Edge cases: if [layoutConfig] is null, loads from the bundled
/// `assets/logical-layout.json` asset. If the active view changes via widget
/// properties, properties subscription and view model are re-synced. Missing
/// JSON files in [_loadJsonOnce] return empty maps (no crash). Layout config
/// loading failures are logged and the UI shows a [CircularProgressIndicator]
/// until [parsedLayout] is ready.
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

  /// Tracks whether the [PropertyGrid] has unsaved edits.
  ///
  /// Used by [_selectView] to show a confirmation dialog before discarding
  /// dirty state when switching views.
  bool _gridIsDirty = false;

  // Data Source
  DataSource? _dataSource;
  StreamSubscription<Map<String, dynamic>>? _propertiesSubscription;
  Map<String, dynamic> _nodeData = const {};

  // Tree ViewModel
  TreeViewModel? _treeViewModel;

  // Properties ViewModel
  PropertiesViewModel? _propertiesViewModel;

  // Actions
  List<ActionDescriptor> _actions = [];
  bool _actionsLoaded = false;

  final _propertyGridKey = GlobalKey();

  static const double _minPaneSize = 150.0;

  /// Subscribes to property changes for the given [nodeId].
  ///
  /// Cancels any previous subscription before creating a new one. Updates
  /// [_nodeData] on each data event. Errors are logged via [debugPrint].
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
        if (mounted) setState(() {
          _nodeData = const {'__error': 'Failed to load properties'};
        });
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
        ..loadTree().then((_) {
          if (mounted) _updateCurrentViewFromLayout();
        }).catchError((Object error) {
          debugPrint('Tree load error: $error');
          if (mounted) setState(() {});
        });
    }
    if (_propertiesViewModel == null) {
      final dataSource = context.read<DataSource>();
      _propertiesViewModel = PropertiesViewModel(dataSource)
        ..loadType(_currentView);
    }
  }

  // Background Worker
  BackgroundWorker? _worker;
  StreamSubscription<int>? _workerSubscription;
  final ValueNotifier<int?> _workerResultNotifier = ValueNotifier<int?>(null);

  // Parsed configuration map
  Map<String, dynamic>? _parsedLayout;

  String? _layoutError;

  // Cached JSON files
  Map<String, dynamic>? _cachedRules;
  Map<String, dynamic>? _cachedLabels;

  /// Loads a JSON file from disk asynchronously, caching results by type.
  ///
  /// Checks [path] and `../$path` for the file; returns an empty map if
  /// neither exists or parsing fails. Caches `codebase_rules` and `labels`
  /// files separately so repeated calls avoid I/O.
  Future<Map<String, dynamic>> _loadJsonOnce(String path) async {
    if (_cachedRules != null && path.contains('codebase_rules')) return _cachedRules!;
    if (_cachedLabels != null && path.contains('labels')) return _cachedLabels!;
    try {
      for (final candidate in [path, '../$path']) {
        final file = File(candidate);
        if (await file.exists()) {
          final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
          if (path.contains('codebase_rules')) _cachedRules = data;
          if (path.contains('labels')) _cachedLabels = data;
          return data;
        }
      }
    } catch (_) {}
    return {};
  }

  // Properties Reactive State

  /// Preloaded topology data from external JSON asset; null until loaded.
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
    _loadActions();

    _worker = BackgroundWorker()..start();
    _workerSubscription = _worker!.results.listen((result) {
      if (mounted) _workerResultNotifier.value = result;
    });

    _preloadTopologyData();
    _preloadCodebaseRules();
  }

  /// Preloads topology data from an external JSON asset for later use.
  ///
  /// Called once during init. Stores the result in [_topologyData]; errors are
  /// logged and do not crash the widget.
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

  /// Preloads codebase rules JSON from disk for later use.
  ///
  /// Called once during init. Populates [_cachedRules] so that
  /// [_getDefaultRatio], [_resolveCoordinateMapping], and
  /// [_resolveLabelsMapping] can read synchronously without blocking the UI
  /// thread. Triggers a rebuild when loading completes.
  Future<void> _preloadCodebaseRules() async {
    await _loadJsonOnce('.pipeline/logical-ui/codebase_rules.json');
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant Layout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeView != null && widget.activeView != oldWidget.activeView) {
      if (_currentView != widget.activeView) {
        setState(() {
          _currentView = widget.activeView!;
        });
        _loadActions();
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
    _workerResultNotifier.dispose();
    _treeViewModel?.dispose();
    _propertiesViewModel?.dispose();
    super.dispose();
  }

  /// Returns the default split ratio for the properties panel.
  ///
  /// Reads from the cached codebase rules; falls back to 0.5 if the rule is
  /// missing or not yet loaded.
  double _getDefaultRatio() {
    return getDefaultRatio(_cachedRules ?? {}, 'layout_properties.default_ratio', 0.5);
  }

  /// Resolves the coordinate-to-location mapping from cached codebase rules.
  Map<String, String> _resolveCoordinateMapping() {
    return resolveCoordinateMapping(_cachedRules ?? {});
  }

  /// Resolves the label mapping from cached codebase rules.
  Map<String, String> _resolveLabelsMapping() {
    return resolveLabelsMapping(_cachedRules ?? {});
  }

  /// Returns a human-readable label for the given [tabId].
  ///
  /// Uses the resolved label mapping first; falls back to hardcoded defaults
  /// for known tab IDs (Items, Status, Activity). Returns the raw [tabId] as a
  /// last resort.
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
  /// Builds a [TopologyData] with the coordinate mapping applied.
  ///
  /// Uses preloaded [_topologyData] if available, otherwise falls back to
  /// [emptyTopologyData].
  TopologyData _resolveTopologyData() {
    final mapping = _resolveCoordinateMapping();
    final data = _topologyData ?? emptyTopologyData;
    return TopologyData(
      coordinateMapping: mapping,
      nodes: data.nodes,
      links: data.links,
    );
  }


  /// Loads the logical layout configuration from the bundled assets.
  ///
  /// Reads `assets/logical-layout.json` and updates the parsed layout and
  /// current view on success. Errors are logged via [debugPrint].
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
      if (mounted) setState(() {
        _layoutError = e.toString();
      });
    }
  }

  /// Updates [_currentView] to the root of the tree data when no explicit
  /// active view is set externally.
  ///
  /// Called after the tree view model loads or changes. If
  /// [widget.activeView] is null and tree data is available, sets the current
  /// view to the first tree node and resubscribes properties.
  void _updateCurrentViewFromLayout() {
    if (widget.activeView == null && _treeViewModel != null && _treeViewModel!.treeData.isNotEmpty) {
      _currentView = _treeViewModel!.treeData.first.id;
      _subscribeProperties(_currentView);
      _propertiesViewModel?.loadType(_currentView);
    }
  }

  /// Selects a view by [viewId], updating state, tree model, properties, and
  /// notifying the parent widget.
  ///
  /// No-op if [viewId] equals [_currentView]. Resubscribes to properties for
  /// the new view and reloads the properties view model type.
  ///
  /// When [PropertyGrid] has unsaved edits ([_gridIsDirty]), a confirmation
  /// dialog is shown before discarding the dirty state and switching views.
  void _selectView(String viewId) {
    if (_currentView == viewId) return;
    if (_gridIsDirty) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text('Discard unsaved changes and switch view?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          _gridIsDirty = false;
          _doSelectView(viewId);
        }
      });
      return;
    }
    _doSelectView(viewId);
  }

  /// Performs the actual view switch after the dirty guard has cleared.
  ///
  /// Extracted from [_selectView] so the dirty-checking logic can be shared
  /// without duplicating the switch body.
  void _doSelectView(String viewId) {
    setState(() {
      _currentView = viewId;
    });
    _loadActions();
    _treeViewModel?.updateCurrentView(viewId);
    _subscribeProperties(viewId);
    _propertiesViewModel?.loadType(viewId);
    widget.onViewChange?.call(viewId);
  }

  /// Builds the full widget tree from the parsed layout configuration.
  ///
  /// Delegates to [ComponentFactory] with the current view, callbacks, and
  /// resolvers. Constrained by [constraints] from the parent [LayoutBuilder].
  Widget _buildFromLayout(BuildContext context, BoxConstraints constraints) {
    final factory = ComponentFactory(
      currentView: _currentView,
      workerResult: _workerResultNotifier,
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
          ? (_layoutError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Layout configuration error', style: Theme.of(context).textTheme.titleLarge),
                      Text(_layoutError!),
                      ElevatedButton(onPressed: _loadLayoutConfig, child: const Text('Retry')),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()))
          : ChangeNotifierProvider<PropertiesViewModel>.value(
              value: _propertiesViewModel!,
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    _buildFromLayout(context, constraints),
              ),
            ),
    );
  }

  /// Builds the child widget displayed in the properties panel.
  ///
  /// Wraps [PropertyGrid] with a [StateIndicator] showing the current lifecycle
  /// state, and an [ActionPanel] below the grid for domain-specific actions.
  /// When the current state is degraded, decommissioned, or failed, the
  /// [PropertyGrid] is rendered read-only.
  ///
  /// Used as a builder callback by [ComponentFactory].
  void _loadActions() {
    _dataSource?.getActions(_currentView).then((actions) {
      if (mounted) setState(() {
        _actions = actions;
        _actionsLoaded = true;
      });
    });
  }

  Widget _buildChildWidget(BuildContext context) {
    final actions = _actions;
    return Consumer<PropertiesViewModel>(
      builder: (context, vm, _) {
        final fields = vm.fields;
        final currentState = vm.currentState;
        final isReadOnly = currentState != null && [
          LifecycleState.degraded,
          LifecycleState.decommissioned,
          LifecycleState.failed,
        ].contains(currentState);

        return SingleChildScrollView(
          child: Column(
            children: [
              if (currentState != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      StateIndicator(state: currentState),
                      const Spacer(),
                    ],
                  ),
                ),
              PropertyGrid(
                key: _propertyGridKey,
                activeView: _currentView,
                fields: fields,
                initialValues: _nodeData,
                readOnly: isReadOnly,
                onViewSelected: (_, id) => _selectView(id),
                onSave: (data) async {
                  await _dataSource!.saveProperties(_currentView, data);
                },
                onDirtyChanged: (dirty) {
                  if (mounted) setState(() => _gridIsDirty = dirty);
                },
              ),
              ActionPanel(
                actions: actions,
                lifecycleState: currentState,
                typeName: _currentView,
                nodeId: _currentView,
                onInvoke: (typeName, nodeId, actionName, params) async {
                  return _dataSource!.invokeAction(typeName, nodeId, actionName, params);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
