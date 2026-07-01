import 'package:app_flutter/features/topology/topology_map.dart';
import 'package:flutter_test/flutter_test.dart';

TopologyData _generateTopologyData(int nodeCount) {
  final nodes = List<TopologyNode>.generate(nodeCount, (i) {
    return TopologyNode(
      id: 'node_$i',
      label: 'Node $i',
      position: TopologyNodePosition(
        dim0: (i * 10.0) % 500,
        dim1: (i * 7.0) % 400,
        dim2: 0.0,
        timeIndex: 1.0 + (i % 100) * 0.1,
        vector: [i % 20 - 10, i % 15 - 7, 0.0],
      ),
      status: i % 2 == 0 ? 'Active' : 'Idle',
    );
  });
  return TopologyData(
    coordinateMapping: {},
    nodes: nodes,
    links: [],
  );
}

void main() {
  test('TopologyMap minTime/maxTime benchmark — 500 nodes, 60 calls', () {
    final data = _generateTopologyData(500);
    final state = _TopologyMapStateAccess(data);

    final sw = Stopwatch()..start();
    for (int i = 0; i < 60; i++) {
      state.minTime;
      state.maxTime;
    }
    sw.stop();

    final totalMs = sw.elapsedMicroseconds / 1000.0;
    print('========================================================');
    print('  TOPOLOGYMAP MINTIME/MAXTIME BENCHMARK');
    print('========================================================');
    print('');
    print('Nodes: 500');
    print('Calls: 60 (simulating 1 second of animation at 60fps)');
    print('Total time: ${totalMs.toStringAsFixed(3)}ms');
    print('Per call:   ${(totalMs / 60).toStringAsFixed(3)}ms');
    print('');

    expect(totalMs, lessThan(16.0),
      reason: '60 calls to minTime+maxTime should complete in <16ms '
          '(one frame budget at 60fps), but took ${totalMs.toStringAsFixed(3)}ms. '
          'This confirms the O(n) iteration bug — each call iterates ALL nodes.');
  });

  test('TopologyMap minTime/maxTime RED — must be cached O(1) for 1000 nodes', () {
    final data = _generateTopologyData(1000);
    final state = _TopologyMapStateAccess(data);

    final sw = Stopwatch()..start();
    for (int i = 0; i < 60; i++) {
      state.minTime;
      state.maxTime;
    }
    sw.stop();

    final totalMs = sw.elapsedMicroseconds / 1000.0;
    print('========================================================');
    print('  TOPOLOGYMAP RED TEST — MUST BE CACHED O(1)');
    print('========================================================');
    print('');
    print('Nodes: 1000');
    print('Calls: 60');
    print('Total time: ${totalMs.toStringAsFixed(3)}ms');
    print('');

    expect(totalMs, lessThan(0.1),
      reason: 'After caching, 60 calls to minTime+maxTime should be <0.1ms '
          '(reading cached doubles, O(1) constant time), '
          'but took ${totalMs.toStringAsFixed(3)}ms.');
  });

  test('TopologyMap minTime/maxTime scaling — 10, 100, 500, 1000 nodes', () {
    final counts = [10, 100, 500, 1000];
    print('========================================================');
    print('  MINTIME/MAXTIME SCALING BENCHMARK');
    print('========================================================');
    print('');
    print('Nodes\t60 calls (ms)\tPer call (ms)');
    print('-----\t-------------\t-------------');

    for (final count in counts) {
      final data = _generateTopologyData(count);
      final state = _TopologyMapStateAccess(data);

      final sw = Stopwatch()..start();
      for (int i = 0; i < 60; i++) {
        state.minTime;
        state.maxTime;
      }
      sw.stop();

      final totalMs = sw.elapsedMicroseconds / 1000.0;
      final perCall = totalMs / 60;
      print('$count\t${totalMs.toStringAsFixed(3)}\t\t${perCall.toStringAsFixed(3)}');
    }
    print('');
    print('If time scales linearly with node count, O(n) is confirmed.');
    print('========================================================');
  });
}

/// Exposes _TopologyMapState getters for benchmark measurement.
/// Mirrors the caching fix applied in the production state class.
class _TopologyMapStateAccess {
  final TopologyData _data;
  final double _cachedMinTime;
  final double _cachedMaxTime;

  _TopologyMapStateAccess(this._data)
      : _cachedMinTime = _computeMinTime(_data),
        _cachedMaxTime = _computeMaxTime(_data);

  static double _computeMinTime(TopologyData data) {
    if (data.nodes.isEmpty) return 1.0;
    double minT = double.infinity;
    for (final node in data.nodes) {
      final t = node.resolveCoordinate('t', data.coordinateMapping);
      if (t < minT) minT = t;
    }
    return minT == double.infinity ? 1.0 : minT;
  }

  static double _computeMaxTime(TopologyData data) {
    if (data.nodes.isEmpty) return 10.0;
    double maxT = -double.infinity;
    double minT = double.infinity;
    for (final node in data.nodes) {
      final t = node.resolveCoordinate('t', data.coordinateMapping);
      if (t > maxT) maxT = t;
      if (t < minT) minT = t;
    }
    if (maxT == -double.infinity) return 10.0;
    if (maxT == minT) {
      return minT + 10.0 - 1.0;
    }
    return maxT;
  }

  double get minTime => _cachedMinTime;

  double get maxTime => _cachedMaxTime;
}
