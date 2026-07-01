import 'package:flutter/cupertino.dart';

import '../../domain/data_source.dart';
import '../../domain/type_descriptor.dart';

class TreeViewModel extends ChangeNotifier {
  final DataSource _dataSource;

  List<InstanceDescriptor> _nodes = [];
  String? _selectedNodeId;

  TreeViewModel(this._dataSource);

  List<InstanceDescriptor> get nodes => _nodes;

  String? get selectedNodeId => _selectedNodeId;

  Future<void> load() async {
    _nodes = await _dataSource.discoverInstances();
    notifyListeners();
  }

  void selectNode(String nodeId) {
    _selectedNodeId = nodeId;
    notifyListeners();
  }
}
