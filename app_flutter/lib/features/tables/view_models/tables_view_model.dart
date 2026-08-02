import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_flutter/features/tables/models/column_model.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/instance_record.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Metadata for a single tab in the table view, derived from either a child
/// type or a related type of the current [TypeDescriptor].
///
/// Exists to pair a display label with the column schema ([columns]) needed to
/// render a tab's table. Created by [TablesViewModel] during discovery.
class TabDescriptor {
  /// Member documentation.
  final String id;
  /// Member documentation.
  final String label;
  /// Member documentation.
  final TypeDescriptor type;

  /// Member documentation.
  const TabDescriptor({
    required this.id,
    required this.label,
    required this.type,
  });
}

/// Drives the tabbed table view by discovering tabs from the data source and
/// fetching tabular data asynchronously.
class TablesViewModel extends ChangeNotifier {
  final DataSource _dataSource;
  String _activeView;
  List<TabDescriptor> _tabs = [];
  String? _selectedTabId;
  List<ColumnModel> _headers = [];
  Set<String>? _hiddenColumnKeys;
  List<List<String>> _rows = [];
  List<ColumnModel> _columnModels = [];
  bool _loading = true;
  String? _error;
  int _requestId = 0;
  bool _disposed = false;

  final Map<(String, String), List<InstanceRecord>> _cache = {};
  StreamSubscription<Result<Map<String, dynamic>>>? _propertiesSubscription;
  Timer? _debounceTimer;

  List<ColumnModel>? _prevVisibleHeaders;
  Set<String>? _prevHiddenKeys;
  List<ColumnModel>? _cachedVisibleModels;

  /// Member documentation.
  TablesViewModel(this._dataSource, this._activeView) {
    _setupPropertiesSubscription(_activeView);
  }

  /// All discovered tabs for the current node. Empty until [loadForNode]
  /// completes successfully and the node has child/related types.
  List<TabDescriptor> get tabs => _tabs;

  /// The currently active tab identifier. Returns the first tab's id if none
  /// is explicitly selected, or an empty string when [tabs] is empty.
  String get tabId =>
      _selectedTabId ?? (_tabs.isNotEmpty ? _tabs.first.id : '');

  /// The currently active tab identifier. `null` before [loadForNode] or when
  /// no tabs exist.
  String? get selectedTabId => _selectedTabId;

  /// Column headers for the currently selected tab.
  List<ColumnModel> get headers => _headers;

  /// Member documentation.
  Set<String>? get hiddenColumnKeys => _hiddenColumnKeys;

  /// Member documentation.
  List<ColumnModel> get visibleColumnModels {
    if (identical(_prevVisibleHeaders, _headers) &&
        identical(_prevHiddenKeys, _hiddenColumnKeys) &&
        _cachedVisibleModels != null) {
      return _cachedVisibleModels!;
    }
    _prevVisibleHeaders = _headers;
    _prevHiddenKeys = _hiddenColumnKeys;
    _cachedVisibleModels = (_hiddenColumnKeys == null ||
            _hiddenColumnKeys!.isEmpty
        ? _headers
        : _headers.where((cm) => !_hiddenColumnKeys!.contains(cm.key)))
        .where((cm) => cm.visible)
        .toList();
    return _cachedVisibleModels!;
  }

  /// Column models for the currently selected tab.
  List<ColumnModel> get columnModels => _columnModels;

  /// Member documentation.
  void setHiddenColumnKeys(Set<String>? keys) {
    _hiddenColumnKeys = keys;
    notifyListeners();
  }

  /// Loaded table rows for the currently selected tab.
  List<List<String>> get rows => _rows;

  /// Whether data is currently being fetched.
  bool get loading => _loading;

  /// Error message if the last fetch failed, or null.
  String? get error => _error;

  /// Discovers tabs and loads the first tab's data for the given [nodeId].
  Future<void> loadForNode(String nodeId) async {
    if (_disposed) return;
    final requestId = ++_requestId;
    _activeView = nodeId;
    _tabs = [];
    _selectedTabId = null;
    _headers = [];
    _rows = [];
    _columnModels = [];
    _loading = true;
    _error = null;
    notifyListeners();
    _setupPropertiesSubscription(nodeId);

    try {
      final typeRes = await _dataSource.typeFor(nodeId);
      if (_disposed || requestId != _requestId) return;
      final typeDescriptor = typeRes.isSuccess ? (typeRes as Success<TypeDescriptor?>).value : null;
      if (typeDescriptor == null) {
        _loading = false;
        notifyListeners();
        return;
      }

      final List<TabDescriptor> tabs = [];

      // 1. Child types (hierarchy containment)
      for (final ct in typeDescriptor.childTypes) {
        final childRes = await _dataSource.typeFor(ct.childTypeName);
        if (_disposed || requestId != _requestId) return;
        final childDesc = childRes.isSuccess ? (childRes as Success<TypeDescriptor?>).value : null;
        if (childDesc == null) continue;
        tabs.add(TabDescriptor(
          id: ct.childTypeName,
          label: ct.childLabel,
          type: childDesc,
        ));
      }

      // 2. Related types (events, alarms, etc.)
      for (final rt in typeDescriptor.relatedTypes) {
        final relRes = await _dataSource.typeFor(rt.childTypeName);
        if (_disposed || requestId != _requestId) return;
        final relDesc = relRes.isSuccess ? (relRes as Success<TypeDescriptor?>).value : null;
        if (relDesc == null) continue;
        tabs.add(TabDescriptor(
          id: rt.childTypeName,
          label: rt.childLabel,
          type: relDesc,
        ));
      }

      if (_disposed || requestId != _requestId) return;

      _tabs = tabs;
      if (tabs.isNotEmpty) {
        _selectedTabId = tabs.first.id;
        await _loadData(tabs.first, requestId);
      } else {
        _selectedTabId = null;
        _rows = [];
        _headers = [];
        _columnModels = [];
        _loading = false;
      }
      notifyListeners();
    } catch (e, st) {
      if (_disposed || requestId != _requestId) return;
      _error = 'Failed to load table data';
      _rows = [];
      _headers = [];
      _columnModels = [];
      _loading = false;
      debugPrint('TablesViewModel.loadForNode error: $e\n$st');
      notifyListeners();
    }
  }

  /// Switches to the tab identified by [tabId] and loads its data.
  Future<void> selectTab(String tabId) async {
    if (_disposed) return;
    if (!_tabs.any((t) => t.id == tabId)) return;
    if (_selectedTabId == tabId) return;
    
    final tab = _tabs.firstWhere((t) => t.id == tabId);
    _selectedTabId = tabId;
    final requestId = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();
    await _loadData(tab, requestId);
  }

  Future<void> _loadData(TabDescriptor tab, int requestId) async {
    if (_disposed || requestId != _requestId) return;
    try {
      _headers = tab.type.fields.map(ColumnModel.fromFieldDescriptor).toList();
      _columnModels = tab.type.fields.map(ColumnModel.fromFieldDescriptor).toList();

      final cacheKey = (_activeView, tab.type.typeName);
      final List<InstanceRecord> records;
      if (_cache.containsKey(cacheKey)) {
        records = _cache[cacheKey]!;
      } else {
        final relRes = await _dataSource.fetchRelatedInstances(
          parentNodeId: _activeView,
          targetType: tab.type,
        );
        if (_disposed || requestId != _requestId) return;
        records = relRes.isSuccess ? (relRes as Success<List<InstanceRecord>>).value : [];
        _cache[cacheKey] = records;
      }

      final rows = records.map((record) {
        return tab.type.fields.map((f) => record.attributes[f.key]?.toString() ?? '').toList();
      }).toList();

      if (_disposed || requestId != _requestId) return;

      _rows = rows;
      _loading = false;
      notifyListeners();
    } catch (e, st) {
      if (_disposed || requestId != _requestId) return;
      _error = 'Failed to load table data';
      _rows = [];
      _headers = [];
      _columnModels = [];
      _loading = false;
      debugPrint('TablesViewModel._loadData error: $e\n$st');
      notifyListeners();
    }
  }

  void _setupPropertiesSubscription(String nodeId) {
    if (_disposed) return;
    _propertiesSubscription?.cancel();
    _debounceTimer?.cancel();
    bool isFirst = true;
    _propertiesSubscription = _dataSource.watchProperties(nodeId).listen(
      (res) {
        if (_disposed) return;
        if (isFirst) {
          isFirst = false;
          return;
        }
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          if (_disposed) return;
          _cache.clear();
          if (_tabs.isNotEmpty && _selectedTabId != null) {
            final tab = _tabs.firstWhere((t) => t.id == _selectedTabId);
            final requestId = ++_requestId;
            _loadData(tab, requestId);
          }
        });
      },
      onError: (Object e) {
        debugPrint('TablesViewModel properties subscription error: $e');
      },
    );
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _propertiesSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
