import 'package:flutter/foundation.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

/// ViewModel for the sidebar tree, consuming [Repository].
class TreeViewModel extends ChangeNotifier {
  final Repository _repository;

  List<InstanceDescriptor> _nodes = [];
  String? _selectedNodeId;

  TreeViewModel(this._repository);

  List<InstanceDescriptor> get nodes => _nodes;
  String? get selectedNodeId => _selectedNodeId;

  Future<void> load() async {
    _nodes = await _repository.discoverInstances();
    notifyListeners();
  }

  void selectNode(String nodeId) {
    if (_selectedNodeId == nodeId) return;
    _selectedNodeId = nodeId;
    notifyListeners();
  }
}
