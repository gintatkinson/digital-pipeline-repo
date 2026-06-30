import 'package:flutter/material.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/repository.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Describes one tab discovered from [TypeDescriptor.childTypes].
class TabDescriptor {
  final String id;
  final String label;
  final List<FieldDescriptor> columns;

  const TabDescriptor({
    required this.id,
    required this.label,
    required this.columns,
  });
}

/// View-model for the tables tabbed container. Discovers tab labels and
/// column headers from the [DataSource]’s [TypeDescriptor.childTypes]
/// instead of hardcoding them.
class TablesViewModel extends ChangeNotifier {
  final AbstractRepository _repository;
  final DataSource _dataSource;
  String _activeView;
  List<TabDescriptor> _tabs = [];
  String? _selectedTabId;
  List<String> _headers = [];
  List<List<String>> _rows = [];
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  TablesViewModel(this._repository, this._dataSource, this._activeView);

  /// All discovered tabs for the current node.
  List<TabDescriptor> get tabs => _tabs;

  /// The currently active tab identifier.
  String get tabId =>
      _selectedTabId ?? (_tabs.isNotEmpty ? _tabs.first.id : '');

  /// The currently active tab identifier.
  String? get selectedTabId => _selectedTabId;

  /// Column headers for the currently selected tab.
  List<String> get headers => _headers;

  /// Loaded table rows for the currently selected tab.
  List<List<String>> get rows => _rows;

  /// Whether data is currently being fetched.
  bool get loading => _loading;

  /// Error message if the last fetch failed, or null.
  String? get error => _error;

  /// Discover tabs and column metadata from [DataSource] for [nodeId]
  /// and load the first tab’s data.
  Future<void> loadForNode(String nodeId) async {
    final requestId = ++_requestId;
    _activeView = nodeId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final typeDescriptor = await _dataSource.typeFor(nodeId);
      if (typeDescriptor == null || requestId != _requestId) return;

      final List<TabDescriptor> tabs = [];
      for (final ct in typeDescriptor.childTypes) {
        final childDesc = await _dataSource.typeFor(ct.childTypeName);
        if (childDesc == null || requestId != _requestId) return;
        tabs.add(TabDescriptor(
          id: ct.childTypeName,
          label: ct.childLabel,
          columns: childDesc.fields,
        ));
      }

      if (requestId != _requestId) return;

      _tabs = tabs;
      if (tabs.isNotEmpty) {
        _selectedTabId = tabs.first.id;
        await _loadData(tabs.first, requestId);
      } else {
        _selectedTabId = null;
        _rows = [];
        _headers = [];
        _loading = false;
      }
      notifyListeners();
    } catch (e, st) {
      if (requestId != _requestId) return;
      _error = 'Failed to load table data';
      _rows = [];
      _headers = [];
      _loading = false;
      debugPrint('TablesViewModel.loadForNode error: $e\n$st');
      notifyListeners();
    }
  }

  /// Switch to a different tab and load its data.
  Future<void> selectTab(String tabId) async {
    final tab = _tabs.firstWhere((t) => t.id == tabId);
    _selectedTabId = tabId;
    final requestId = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();
    await _loadData(tab, requestId);
  }

  Future<void> _loadData(TabDescriptor tab, int requestId) async {
    try {
      _headers = tab.columns.map((f) => f.label).toList();
      final data = await _repository.fetchElements(_activeView);

      if (requestId != _requestId) return;

      final rows = data.map((row) {
        return tab.columns.map((f) => row[f.key] as String? ?? '').toList();
      }).toList();

      if (requestId != _requestId) return;

      _rows = rows;
      _loading = false;
      notifyListeners();
    } catch (e, st) {
      if (requestId != _requestId) return;
      _error = 'Failed to load table data';
      _rows = [];
      _headers = [];
      _loading = false;
      debugPrint('TablesViewModel._loadData error: $e\n$st');
      notifyListeners();
    }
  }
}
