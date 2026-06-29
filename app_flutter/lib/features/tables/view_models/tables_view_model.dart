import 'package:flutter/material.dart';
import 'package:app_flutter/domain/repository.dart';

/// View-model for a table tab. Loads rows/headers from the repository
/// based on the tab type (sub-elements, alarms, or events).
class TablesViewModel extends ChangeNotifier {
  final AbstractRepository _repository;
  String _tabId;
  String _activeView;
  List<List<String>> _rows = [];
  List<String> _headers = [];
  bool _loading = true;
  String? _error;
  int _requestId = 0;

  TablesViewModel(this._repository, this._tabId, this._activeView) {
    _loadData();
  }

  /// The tab identifier (e.g. `'sub_elements_table'`).
  String get tabId => _tabId;

  /// The loaded table rows (list of string lists).
  List<List<String>> get rows => _rows;

  /// The loaded column headers.
  List<String> get headers => _headers;

  /// Whether data is currently being fetched.
  bool get loading => _loading;

  /// Error message if the last fetch failed, or null if no error.
  String? get error => _error;

  /// Triggers a reload of table data.
  void reload(String tabId, String activeView) {
    _tabId = tabId;
    _activeView = activeView;
    _loadData();
  }

  Future<void> _loadData() async {
    final requestId = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final nodeId = _activeView;

      List<Map<String, dynamic>> data;
      List<String> headers;

      if (_tabId == 'sub_elements_table') {
        data = await _repository.fetchElements(nodeId);
        headers = ['ID', 'Name', 'Type', 'Status'];
      } else if (_tabId == 'active_alarms_table') {
        data = await _repository.fetchAlarms(nodeId);
        headers = ['Alarm ID', 'Target', 'Severity', 'Timestamp'];
      } else {
        data = await _repository.fetchEvents(nodeId);
        headers = ['Event ID', 'Source', 'Message', 'Timestamp'];
      }

      if (requestId != _requestId) return;

      final rows = data.map((row) {
        if (_tabId == 'sub_elements_table') {
          return [
            row['id'] as String? ?? '',
            row['name'] as String? ?? '',
            row['type'] as String? ?? '',
            row['status'] as String? ?? '',
          ];
        } else if (_tabId == 'active_alarms_table') {
          return [
            row['id'] as String? ?? '',
            row['target'] as String? ?? '',
            row['severity'] as String? ?? '',
            row['timestamp'] as String? ?? '',
          ];
        } else {
          return [
            row['id'] as String? ?? '',
            row['source'] as String? ?? '',
            row['message'] as String? ?? '',
            row['timestamp'] as String? ?? '',
          ];
        }
      }).toList();

      if (requestId != _requestId) return;

      _headers = headers;
      _rows = rows;
      _loading = false;
    } catch (e, st) {
      if (requestId != _requestId) return;
      _error = 'Failed to load table data';
      _rows = [];
      _headers = [];
      _loading = false;
      debugPrint('TablesViewModel._loadData error: $e\n$st');
    }
    notifyListeners();
  }
}
