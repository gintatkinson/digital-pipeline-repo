import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pipeline_app/domain/repository.dart';

/// A positioned node rendered on the topology canvas.
class TopologyNode {
  final String id;
  final double d0;
  final double d1;
  const TopologyNode({required this.id, required this.d0, required this.d1});
}

/// A directed connection between two [TopologyNode] instances.
class TopologyLink {
  final String fromId;
  final String toId;
  const TopologyLink({required this.fromId, required this.toId});
}

/// ViewModel for the topology canvas, consuming [Repository].
class TopologyViewModel extends ChangeNotifier {
  final Repository _repository;
  final int _maxDepthHops = 3;
  int _depthHops = 1;
  double _timeIndex = 0.0;
  bool _isPlaying = false;
  List<TopologyNode> _nodes = [];
  List<TopologyLink> _links = [];
  String? _selectedNodeId;

  TopologyViewModel(this._repository);

  int get depthHops => _depthHops;
  int get maxDepthHops => _maxDepthHops;
  double get timeIndex => _timeIndex;
  bool get isPlaying => _isPlaying;
  List<TopologyNode> get nodes => _nodes;
  List<TopologyLink> get links => _links;
  String? get selectedNodeId => _selectedNodeId;

  Future<void> loadTopologyData() async {
    final instances = await _repository.discoverInstances();
    final rawNodes = instances
        .map((i) => TopologyNode(id: i.nodeId, d0: 0, d1: 0))
        .toList();
    _nodes = _positionNodes(rawNodes);

    final links = <TopologyLink>[];
    for (final inst in instances) {
      final td = await _repository.typeFor(inst.typeName);
      if (td != null) {
        for (final rel in td.childTypes) {
          final children = await _repository.fetchChildren(inst.nodeId, rel.relationName);
          for (final child in children) {
            final childId = child['id'] as String?;
            if (childId != null) {
              links.add(TopologyLink(fromId: inst.nodeId, toId: childId));
            }
          }
        }
      }
    }
    _links = links;
    notifyListeners();
  }

  List<TopologyNode> _positionNodes(List<TopologyNode> instances) {
    final count = instances.length;
    if (count == 0) return [];
    const radius = 150.0;
    const center = 200.0;
    return List.generate(count, (i) {
      final angle = (2 * pi * i) / count;
      return TopologyNode(
        id: instances[i].id,
        d0: center + radius * cos(angle),
        d1: center + radius * sin(angle),
      );
    });
  }

  void selectNode(String nodeId) {
    _selectedNodeId = nodeId;
    notifyListeners();
  }

  void setDepthHops(int hops) {
    _depthHops = hops.clamp(1, _maxDepthHops);
    notifyListeners();
  }

  void setTimeIndex(double index) {
    _timeIndex = index;
    notifyListeners();
  }

  void togglePlaying() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }
}
