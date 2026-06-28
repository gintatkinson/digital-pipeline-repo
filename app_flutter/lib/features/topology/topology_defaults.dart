import 'package:app_flutter/features/topology/topology_map.dart';

// TODO(#79): Replace mock topology data with dynamic DB-backed data.
// Currently used as fallback when widget.data is null.
// Source: layout.dart _resolveTopologyData() passes this default data to TopologyMap.
final TopologyData defaultTopologyData = TopologyData(
  coordinateMapping: const <String, String>{
    'x': 'position/dim_0',
    'y': 'position/dim_1',
    'z': 'position/dim_2',
    't': 'position/time_index',
    'trajectory': 'position/vector',
  },
  nodes: const <TopologyNode>[
    TopologyNode(
      id: 'Ingestion',
      label: 'Ingestion',
      position: TopologyNodePosition(
        dim0: 100,
        dim1: 140,
        dim2: 0.0,
        timeIndex: 1.0,
        vector: <double>[15, 3, 0.0],
      ),
      status: 'Active',
    ),
    TopologyNode(
      id: 'Metrics',
      label: 'Metrics',
      position: TopologyNodePosition(
        dim0: 320,
        dim1: 90,
        dim2: 0.0,
        timeIndex: 1.0,
        vector: <double>[8, -4, 0.0],
      ),
      status: 'Active',
    ),
    TopologyNode(
      id: 'Location',
      label: 'Location',
      position: TopologyNodePosition(
        dim0: 240,
        dim1: 220,
        dim2: 0.0,
        timeIndex: 1.0,
        vector: <double>[4, 10, 0.0],
      ),
      status: 'Active',
    ),
    TopologyNode(
      id: 'Chassis',
      label: 'Chassis',
      position: TopologyNodePosition(
        dim0: 480,
        dim1: 180,
        dim2: 0.0,
        timeIndex: 1.0,
        vector: <double>[-6, 6, 0.0],
      ),
      status: 'Idle',
    ),
  ],
  links: const <TopologyLink>[
    TopologyLink(source: 'Ingestion', target: 'Metrics', type: 'data-flow'),
    TopologyLink(source: 'Metrics', target: 'Chassis', type: 'data-flow'),
    TopologyLink(source: 'Location', target: 'Chassis', type: 'data-flow'),
  ],
);
