import 'package:flutter/material.dart';
import 'package:app_flutter/domain/repository.dart';

class TablesViewModel extends ChangeNotifier {
  final AbstractRepository _repository;
  final String _tabId;
  final String _activeView;
  List<List<String>> _rows = [];
  List<String> _headers = [];
  bool _loading = true;

  TablesViewModel(this._repository, this._tabId, this._activeView) {
    _loadData();
  }

  String get tabId => _tabId;
  List<List<String>> get rows => _rows;
  List<String> get headers => _headers;
  bool get loading => _loading;

  void reload(String tabId, String activeView) {
    _loadData();
  }

  Future<void> _loadData() async {
    _loading = true;
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

      _headers = headers;
      _rows = rows;
      _loading = false;
    } catch (_) {
      _loading = false;
    }
    notifyListeners();
  }
}
