import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:app_flutter/features/topology/topology_defaults.dart' show emptyTopologyData;

dynamic _resolvePath(Map<String, dynamic> map, String path) {
  final List<String> parts = path.split('/');
  dynamic current = map;
  for (final String part in parts) {
    if (current is Map<String, dynamic>) {
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}

/// Position details for a node in the network topology.
class TopologyNodePosition {
  final double dim0;
  final double dim1;
  final double dim2;
  final double timeIndex;
  final List<double> vector;
  final Map<String, dynamic> rawProperties;

  const TopologyNodePosition({
    required this.dim0,
    required this.dim1,
    required this.dim2,
    required this.timeIndex,
    required this.vector,
    this.rawProperties = const <String, dynamic>{},
  });

  factory TopologyNodePosition.fromJson(Map<String, dynamic> json) {
    return TopologyNodePosition(
      dim0: (json['dim_0'] as num?)?.toDouble() ?? 0.0,
      dim1: (json['dim_1'] as num?)?.toDouble() ?? 0.0,
      dim2: (json['dim_2'] as num?)?.toDouble() ?? 0.0,
      timeIndex: (json['time_index'] as num?)?.toDouble() ?? 0.0,
      vector: json['vector'] is List<dynamic>
          ? (json['vector'] as List<dynamic>)
              .map((dynamic e) => (e as num).toDouble())
              .toList()
          : <double>[],
      rawProperties: json,
    );
  }

  String? _resolvePathWithMapping(String key, Map<String, String>? coordinateMapping) {
    final String? path = coordinateMapping?[key];
    if (path == null) return null;
    return path.startsWith('position/') ? path.substring(9) : path;
  }

  double resolveCoordinate(String key, Map<String, String>? coordinateMapping) {
    final String? resolvedPath = _resolvePathWithMapping(key, coordinateMapping);
    if (resolvedPath != null) {
      final dynamic val = _resolvePath(rawProperties, resolvedPath);
      if (val is num) {
        return val.toDouble();
      }
    }
    switch (key) {
      case 'x':
        return dim0;
      case 'y':
        return dim1;
      case 'z':
        return dim2;
      case 't':
        return timeIndex;
      default:
        return 0.0;
    }
  }

  List<double> resolveVector(String key, Map<String, String>? coordinateMapping) {
    final String? resolvedPath = _resolvePathWithMapping(key, coordinateMapping);
    if (resolvedPath != null) {
      final dynamic val = _resolvePath(rawProperties, resolvedPath);
      if (val is List) {
        return val.map((dynamic e) => (e as num).toDouble()).toList();
      }
    }
    if (key == 'trajectory') {
      return vector;
    }
    return const <double>[];
  }
}

/// Represents a single node in the topology map.
class TopologyNode {
  final String id;
  final String label;
  final TopologyNodePosition position;
  final String status;
  final Map<String, dynamic> rawProperties;

  const TopologyNode({
    required this.id,
    required this.label,
    required this.position,
    required this.status,
    this.rawProperties = const <String, dynamic>{},
  });

  factory TopologyNode.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> posJson = json['position'] is Map<String, dynamic>
        ? json['position'] as Map<String, dynamic>
        : <String, dynamic>{};
    return TopologyNode(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      position: TopologyNodePosition.fromJson(posJson),
      status: json['status'] as String? ?? '',
      rawProperties: json,
    );
  }

  double resolveCoordinate(String key, Map<String, String>? coordinateMapping) {
    final String? path = coordinateMapping?[key];
    if (path != null && rawProperties.isNotEmpty) {
      final dynamic val = _resolvePath(rawProperties, path);
      if (val is num) {
        return val.toDouble();
      }
    }
    return position.resolveCoordinate(key, coordinateMapping);
  }

  List<double> resolveVector(String key, Map<String, String>? coordinateMapping) {
    final String? path = coordinateMapping?[key];
    if (path != null && rawProperties.isNotEmpty) {
      final dynamic val = _resolvePath(rawProperties, path);
      if (val is List) {
        return val.map((dynamic e) => (e as num).toDouble()).toList();
      }
    }
    return position.resolveVector(key, coordinateMapping);
  }

  Offset computePosition(TopologyData data, double timeIndex) {
    final double nodeT = resolveCoordinate('t', data.coordinateMapping);
    final double dt = timeIndex - nodeT;
    final List<double> vector = resolveVector('trajectory', data.coordinateMapping);
    final double vx = vector.isNotEmpty ? vector[0] : 0.0;
    final double vy = vector.length > 1 ? vector[1] : 0.0;
    final double nodeX = resolveCoordinate('x', data.coordinateMapping);
    final double nodeY = resolveCoordinate('y', data.coordinateMapping);
    return Offset(nodeX + dt * vx, nodeY + dt * vy);
  }
}

/// Represents a link (connection) between two nodes.
class TopologyLink {
  final String source;
  final String target;
  final String type;

  const TopologyLink({
    required this.source,
    required this.target,
    required this.type,
  });

  factory TopologyLink.fromJson(Map<String, dynamic> json) {
    return TopologyLink(
      source: json['source'] as String? ?? '',
      target: json['target'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

/// Consolidated topology data configuration.
class TopologyData {
  final Map<String, String> coordinateMapping;
  final List<TopologyNode> nodes;
  final List<TopologyLink> links;

  const TopologyData({
    required this.coordinateMapping,
    required this.nodes,
    required this.links,
  });

  factory TopologyData.fromJson(Map<String, dynamic> json) {
    return TopologyData(
      coordinateMapping: Map<String, String>.from(
        json['coordinate_mapping'] as Map,
      ),
      nodes: (json['nodes'] as List<dynamic>)
          .map((n) => TopologyNode.fromJson(n as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List<dynamic>)
          .map((l) => TopologyLink.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// TopologyMap Widget
///
/// Realizes UML::TopologyMap and UML::PlaybackController.
class TopologyMap extends StatefulWidget {
  final String? activeFocusedNode;
  final ValueChanged<String>? onNodeSelect;
  final TopologyData? data;

  const TopologyMap({
    super.key,
    this.activeFocusedNode,
    this.onNodeSelect,
    this.data,
  });

  @override
  State<TopologyMap> createState() => _TopologyMapState();
}

class _TopologyMapState extends State<TopologyMap>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double currentTimeIndex = 1.0;
  double playbackSpeedMultiplier = 1.0;
  bool isPlaying = false;
  Duration _lastElapsed = Duration.zero;

  double get minTime {
    final TopologyData activeData = widget.data ?? emptyTopologyData;
    if (activeData.nodes.isEmpty) return 1.0;
    double minT = double.infinity;
    for (final TopologyNode node in activeData.nodes) {
      final double t = node.resolveCoordinate('t', activeData.coordinateMapping);
      if (t < minT) minT = t;
    }
    return minT == double.infinity ? 1.0 : minT;
  }

  double get maxTime {
    final TopologyData activeData = widget.data ?? emptyTopologyData;
    if (activeData.nodes.isEmpty) return 10.0;
    double maxT = -double.infinity;
    for (final TopologyNode node in activeData.nodes) {
      final double t = node.resolveCoordinate('t', activeData.coordinateMapping);
      if (t > maxT) maxT = t;
    }
    if (maxT == -double.infinity) return 10.0;
    final double minT = minTime;
    if (maxT == minT) {
      return minT + 9.0;
    }
    return maxT;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    currentTimeIndex = minTime;
  }

  @override
  void didUpdateWidget(covariant TopologyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      final double minT = minTime;
      final double maxT = maxTime;
      if (currentTimeIndex < minT || currentTimeIndex > maxT) {
        currentTimeIndex = minT;
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final double deltaSeconds =
        (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (isPlaying) {
      final double minT = minTime;
      final double maxT = maxTime;
      setState(() {
        currentTimeIndex += deltaSeconds * playbackSpeedMultiplier;
        if (currentTimeIndex > maxT) {
          currentTimeIndex = minT; // Loop back
        }
      });
    }
  }

  void togglePlayback() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _lastElapsed = Duration.zero;
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });
  }

  void setPlayhead(double timeIndex) {
    final double minT = minTime;
    final double maxT = maxTime;
    setState(() {
      currentTimeIndex = timeIndex.clamp(minT, maxT);
    });
  }

  void _handleTap(TapUpDetails details) {
    final TopologyData activeData = widget.data ?? emptyTopologyData;
    final double clickX = details.localPosition.dx;
    final double clickY = details.localPosition.dy;

    for (final TopologyNode node in activeData.nodes) {
      final Offset pos = node.computePosition(activeData, currentTimeIndex);
      final double dist = math.sqrt(
          (clickX - pos.dx) * (clickX - pos.dx) +
              (clickY - pos.dy) * (clickY - pos.dy));

      if (dist <= 20.0) {
        widget.onNodeSelect?.call(node.id);
        break;
      }
    }
  }

  Widget _buildPlaybackPanel(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colors.outlineVariant, width: 1.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          ElevatedButton(
            key: const ValueKey<String>('playPauseButton'),
            onPressed: togglePlayback,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPlaying ? colors.error : colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 6.0),
              minimumSize: const Size(70, 32),
            ),
            child: Text(
              isPlaying ? 'Pause' : 'Play',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('t:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 8),
              SizedBox(
                width: 32.0,
                child: Text(
                  currentTimeIndex.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              key: const ValueKey<String>('timeSlider'),
              min: minTime,
              max: maxTime,
              divisions: 90,
              value: currentTimeIndex.clamp(minTime, maxTime),
              onChanged: (double value) {
                setPlayhead(value);
              },
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Speed:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
              DropdownButton<double>(
                key: const ValueKey<String>('speedDropdown'),
                value: playbackSpeedMultiplier,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down),
                style: Theme.of(context).textTheme.bodySmall,
                items: const <DropdownMenuItem<double>>[
                  DropdownMenuItem<double>(value: 0.5, child: Text('0.5x')),
                  DropdownMenuItem<double>(value: 1.0, child: Text('1.0x')),
                  DropdownMenuItem<double>(value: 2.0, child: Text('2.0x')),
                  DropdownMenuItem<double>(value: 5.0, child: Text('5.0x')),
                ],
                onChanged: (double? value) {
                  if (value != null) {
                    setState(() {
                      playbackSpeedMultiplier = value;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TopologyData activeData = widget.data ?? emptyTopologyData;

    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewportWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 800.0;
        final double viewportHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 500.0;
        final double width = viewportWidth > 800.0 ? viewportWidth : 800.0;
        final double height = viewportHeight > 500.0 ? viewportHeight : 500.0;

        return Container(
          color: colors.surfaceContainerHighest,
          child: Column(
            children: <Widget>[
              // Scrollable Canvas Viewport
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (TapUpDetails details) =>
                            _handleTap(details),
                        child: CustomPaint(
                          size: Size(width, height),
                          painter: TopologyPainter(
                            activeFocusedNode: widget.activeFocusedNode,
                            activeData: activeData,
                            currentTimeIndex: currentTimeIndex,
                            bgColor: colors.surfaceContainerHighest,
                            gridColor: colors.outlineVariant,
                            linkColor: colors.primary.withValues(alpha: 0.35),
                            packetColor: colors.primary,
                            velocityColor: colors.error.withValues(alpha: 0.4),
                            nodeFillColor: colors.primary,
                            nodeStrokeColor: colors.onPrimary,
                            activeStatusColor: colors.tertiary,
                            warningStatusColor: colors.error,
                            haloColor: colors.primary.withValues(alpha: 0.3),
                            labelColor: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildPlaybackPanel(colors),
            ],
          ),
        );
      },
    );
  }
}

/// CanvasRenderer implementing node projection and line rendering.
class TopologyPainter extends CustomPainter {
  final String? activeFocusedNode;
  final TopologyData activeData;
  final double currentTimeIndex;
  final Color bgColor;
  final Color gridColor;
  final Color linkColor;
  final Color packetColor;
  final Color velocityColor;
  final Color nodeFillColor;
  final Color nodeStrokeColor;
  final Color activeStatusColor;
  final Color warningStatusColor;
  final Color haloColor;
  final Color labelColor;

  TopologyPainter({
    required this.activeFocusedNode,
    required this.activeData,
    required this.currentTimeIndex,
    required this.bgColor,
    required this.gridColor,
    required this.linkColor,
    required this.packetColor,
    required this.velocityColor,
    required this.nodeFillColor,
    required this.nodeStrokeColor,
    required this.activeStatusColor,
    required this.warningStatusColor,
    required this.haloColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw background
    final Paint bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Draw grid lines every 40px
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 40.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Compute projected positions
    final Map<String, Offset> projectedPositions = <String, Offset>{};
    for (final TopologyNode node in activeData.nodes) {
      projectedPositions[node.id] = node.computePosition(activeData, currentTimeIndex);
    }

    // 4. Draw links
    for (final TopologyLink link in activeData.links) {
      final Offset? sourceOffset = projectedPositions[link.source];
      final Offset? targetOffset = projectedPositions[link.target];

      if (sourceOffset != null && targetOffset != null) {
        // Connector link line
        final Paint linkPaint = Paint()
          ..color = linkColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(sourceOffset, targetOffset, linkPaint);

        // Animated data packet along link path
        final double packetRatio = (currentTimeIndex % 2.0) / 2.0;
        final double px =
            sourceOffset.dx + (targetOffset.dx - sourceOffset.dx) * packetRatio;
        final double py =
            sourceOffset.dy + (targetOffset.dy - sourceOffset.dy) * packetRatio;

        final Paint packetPaint = Paint()
          ..color = packetColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(px, py), 4.0, packetPaint);
      }
    }

    // 5. Draw nodes
    for (final TopologyNode node in activeData.nodes) {
      final Offset? pos = projectedPositions[node.id];
      if (pos == null) continue;

      final bool isFocused = activeFocusedNode == node.id;
      final List<double> vector = node.resolveVector('trajectory', activeData.coordinateMapping);
      final double vx = vector.isNotEmpty ? vector[0] : 0.0;
      final double vy = vector.length > 1 ? vector[1] : 0.0;

      // Velocity vector line
      final Paint vectorPaint = Paint()
        ..color = velocityColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          pos, Offset(pos.dx + vx * 2.0, pos.dy + vy * 2.0), vectorPaint);

      // Node base circle representation
      final Paint fillPaint = Paint()..style = PaintingStyle.fill;
      final Paint strokePaint = Paint()..style = PaintingStyle.stroke;
      final double radius = isFocused ? 12.0 : 9.0;

      if (isFocused) {
        fillPaint.color = nodeFillColor;
        strokePaint
          ..color = nodeStrokeColor
          ..strokeWidth = 2.5;
      } else {
        fillPaint.color = node.status == 'Active'
            ? activeStatusColor
            : warningStatusColor;
        strokePaint
          ..color = gridColor
          ..strokeWidth = 2.0;
      }

      canvas.drawCircle(pos, radius, fillPaint);
      canvas.drawCircle(pos, radius, strokePaint);

      // Pulsing halo ring around focused node
      if (isFocused) {
        final Paint haloPaint = Paint()
          ..color = haloColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(pos, 20.0, haloPaint);
      }

      // Draw node label below
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2.0, pos.dy + 14.0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TopologyPainter oldDelegate) {
    return oldDelegate.currentTimeIndex != currentTimeIndex ||
        oldDelegate.activeFocusedNode != activeFocusedNode ||
        oldDelegate.activeData != activeData ||
        oldDelegate.bgColor != bgColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.linkColor != linkColor ||
        oldDelegate.packetColor != packetColor ||
        oldDelegate.velocityColor != velocityColor ||
        oldDelegate.nodeFillColor != nodeFillColor ||
        oldDelegate.nodeStrokeColor != nodeStrokeColor ||
        oldDelegate.activeStatusColor != activeStatusColor ||
        oldDelegate.warningStatusColor != warningStatusColor ||
        oldDelegate.haloColor != haloColor ||
        oldDelegate.labelColor != labelColor;
  }
}
