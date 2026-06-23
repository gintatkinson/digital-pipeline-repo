import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Position details for a node in the network topology.
class TopologyNodePosition {
  final double dim0;
  final double dim1;
  final double dim2;
  final double timeIndex;
  final List<double> vector;

  const TopologyNodePosition({
    required this.dim0,
    required this.dim1,
    required this.dim2,
    required this.timeIndex,
    required this.vector,
  });

  factory TopologyNodePosition.fromJson(Map<String, dynamic> json) {
    return TopologyNodePosition(
      dim0: (json['dim_0'] as num).toDouble(),
      dim1: (json['dim_1'] as num).toDouble(),
      dim2: (json['dim_2'] as num).toDouble(),
      timeIndex: (json['time_index'] as num).toDouble(),
      vector: (json['vector'] as List<dynamic>)
          .map((dynamic e) => (e as num).toDouble())
          .toList(),
    );
  }
}

/// Represents a single node in the topology map.
class TopologyNode {
  final String id;
  final String label;
  final TopologyNodePosition position;
  final String status;

  const TopologyNode({
    required this.id,
    required this.label,
    required this.position,
    required this.status,
  });

  factory TopologyNode.fromJson(Map<String, dynamic> json) {
    return TopologyNode(
      id: json['id'] as String,
      label: json['label'] as String,
      position: TopologyNodePosition.fromJson(
          json['position'] as Map<String, dynamic>),
      status: json['status'] as String,
    );
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
      source: json['source'] as String,
      target: json['target'] as String,
      type: json['type'] as String,
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
}

/// Default mock topology data matching the React implementation.
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
  late final ScrollController _contentVerticalController;
  late final ScrollController _scrollbarVerticalController;
  late final ScrollController _contentHorizontalController;
  late final ScrollController _scrollbarHorizontalController;
  bool _isSyncingVertical = false;
  bool _isSyncingHorizontal = false;
  double currentTimeIndex = 1.0;
  double playbackSpeedMultiplier = 1.0;
  bool isPlaying = false;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _contentVerticalController = ScrollController();
    _scrollbarVerticalController = ScrollController();
    _contentHorizontalController = ScrollController();
    _scrollbarHorizontalController = ScrollController();

    _contentVerticalController.addListener(() {
      if (_isSyncingVertical) return;
      _isSyncingVertical = true;
      if (_scrollbarVerticalController.hasClients) {
        _scrollbarVerticalController.jumpTo(_contentVerticalController.offset);
      }
      _isSyncingVertical = false;
    });

    _scrollbarVerticalController.addListener(() {
      if (_isSyncingVertical) return;
      _isSyncingVertical = true;
      if (_contentVerticalController.hasClients) {
        _contentVerticalController.jumpTo(_scrollbarVerticalController.offset);
      }
      _isSyncingVertical = false;
    });

    _contentHorizontalController.addListener(() {
      if (_isSyncingHorizontal) return;
      _isSyncingHorizontal = true;
      if (_scrollbarHorizontalController.hasClients) {
        _scrollbarHorizontalController.jumpTo(_contentHorizontalController.offset);
      }
      _isSyncingHorizontal = false;
    });

    _scrollbarHorizontalController.addListener(() {
      if (_isSyncingHorizontal) return;
      _isSyncingHorizontal = true;
      if (_contentHorizontalController.hasClients) {
        _contentHorizontalController.jumpTo(_scrollbarHorizontalController.offset);
      }
      _isSyncingHorizontal = false;
    });

    _ticker = createTicker(_onTick);
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
      setState(() {
        currentTimeIndex += deltaSeconds * playbackSpeedMultiplier;
        if (currentTimeIndex > 10.0) {
          currentTimeIndex = 1.0; // Loop back
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
    setState(() {
      currentTimeIndex = timeIndex.clamp(1.0, 10.0);
    });
  }

  void _handleTap(TapUpDetails details, double width, double height) {
    final TopologyData activeData = widget.data ?? defaultTopologyData;
    final double clickX = details.localPosition.dx;
    final double clickY = details.localPosition.dy;

    for (final TopologyNode node in activeData.nodes) {
      final double dt = currentTimeIndex - node.position.timeIndex;
      final double vx =
          node.position.vector.isNotEmpty ? node.position.vector[0] : 0.0;
      final double vy =
          node.position.vector.length > 1 ? node.position.vector[1] : 0.0;

      final double nodeX = node.position.dim0 + dt * vx;
      final double nodeY = node.position.dim1 + dt * vy;

      final double dist = math.sqrt(
          (clickX - nodeX) * (clickX - nodeX) +
              (clickY - nodeY) * (clickY - nodeY));

      if (dist <= 20.0) {
        widget.onNodeSelect?.call(node.id);
        break;
      }
    }
  }

  @override
  void dispose() {
    _contentVerticalController.dispose();
    _scrollbarVerticalController.dispose();
    _contentHorizontalController.dispose();
    _scrollbarHorizontalController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TopologyData activeData = widget.data ?? defaultTopologyData;

    return Theme(
      data: ThemeData.dark().copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0x80FFFFFF)),
          trackColor: WidgetStateProperty.all(const Color(0x14FFFFFF)),
          trackVisibility: WidgetStateProperty.all(true),
          thickness: WidgetStateProperty.all(8.0),
          radius: const Radius.circular(4.0),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double viewportWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 800.0;
          final double viewportHeight =
              constraints.maxHeight.isFinite ? constraints.maxHeight : 500.0;
          final double width = viewportWidth > 800.0 ? viewportWidth : 800.0;
          final double height = viewportHeight > 500.0 ? viewportHeight : 500.0;

          return Container(
            color: const Color(0xFF0F172A),
            child: Column(
              children: <Widget>[
                // Scrollable Canvas Viewport
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      // Main content
                      Positioned.fill(
                        child: SingleChildScrollView(
                          controller: _contentVerticalController,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            controller: _contentHorizontalController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: width,
                              height: height,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapUp: (TapUpDetails details) =>
                                    _handleTap(details, width, height),
                                child: CustomPaint(
                                  size: Size(width, height),
                                  painter: TopologyPainter(
                                    activeFocusedNode: widget.activeFocusedNode,
                                    activeData: activeData,
                                    currentTimeIndex: currentTimeIndex,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Vertical Scrollbar
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 12,
                        width: 12,
                        child: Scrollbar(
                          controller: _scrollbarVerticalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollbarVerticalController,
                            scrollDirection: Axis.vertical,
                            child: SizedBox(
                              height: height,
                            ),
                          ),
                        ),
                      ),
                      // Horizontal Scrollbar
                      Positioned(
                        left: 0,
                        right: 12,
                        bottom: 0,
                        height: 12,
                        child: Scrollbar(
                          controller: _scrollbarHorizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollbarHorizontalController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: width,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Playback Scrubber Panel
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(
                      top: BorderSide(color: Color(0xFF1E293B), width: 1.0),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Play/Pause button
                      ElevatedButton(
                        key: const ValueKey<String>('playPauseButton'),
                        onPressed: togglePlayback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPlaying
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          minimumSize: const Size(70, 32),
                        ),
                        child: Text(
                          isPlaying ? 'Pause' : 'Play',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.0),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Current time index display
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            't:',
                            style:
                                TextStyle(color: Color(0xFF94A3B8), fontSize: 13.0),
                          ),
                          const SizedBox(width: 8.0),
                          SizedBox(
                            width: 32.0,
                            child: Text(
                              currentTimeIndex.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      // Timeline Slider
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6.0,
                            activeTrackColor: const Color(0xFF3B82F6),
                            inactiveTrackColor: const Color(0xFF1E293B),
                            thumbColor: const Color(0xFF3B82F6),
                            overlayColor: const Color(0x293B82F6),
                          ),
                          child: Slider(
                            key: const ValueKey<String>('timeSlider'),
                            min: 1.0,
                            max: 10.0,
                            divisions: 90,
                            value: currentTimeIndex,
                            onChanged: (double value) {
                              setPlayhead(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Speed dropdown
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'Speed:',
                            style:
                                TextStyle(color: Color(0xFF94A3B8), fontSize: 12.0),
                          ),
                          const SizedBox(width: 6.0),
                          Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: const Color(0xFF1E293B),
                            ),
                            child: DropdownButton<double>(
                              key: const ValueKey<String>('speedDropdown'),
                              value: playbackSpeedMultiplier,
                              underline: const SizedBox.shrink(),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF94A3B8)),
                              style: const TextStyle(
                                  color: Color(0xFFF8FAFC), fontSize: 12.0),
                              items: const <DropdownMenuItem<double>>[
                                DropdownMenuItem<double>(
                                    value: 0.5, child: Text('0.5x')),
                                DropdownMenuItem<double>(
                                    value: 1.0, child: Text('1.0x')),
                                DropdownMenuItem<double>(
                                    value: 2.0, child: Text('2.0x')),
                                DropdownMenuItem<double>(
                                    value: 5.0, child: Text('5.0x')),
                              ],
                              onChanged: (double? value) {
                                if (value != null) {
                                  setState(() {
                                    playbackSpeedMultiplier = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// CanvasRenderer implementing node projection and line rendering.
class TopologyPainter extends CustomPainter {
  final String? activeFocusedNode;
  final TopologyData activeData;
  final double currentTimeIndex;

  TopologyPainter({
    required this.activeFocusedNode,
    required this.activeData,
    required this.currentTimeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw dark background
    final Paint bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Draw grid lines every 40px
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
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
      final double dt = currentTimeIndex - node.position.timeIndex;
      final double vx =
          node.position.vector.isNotEmpty ? node.position.vector[0] : 0.0;
      final double vy =
          node.position.vector.length > 1 ? node.position.vector[1] : 0.0;

      final double x = node.position.dim0 + dt * vx;
      final double y = node.position.dim1 + dt * vy;
      projectedPositions[node.id] = Offset(x, y);
    }

    // 4. Draw links
    for (final TopologyLink link in activeData.links) {
      final Offset? sourceOffset = projectedPositions[link.source];
      final Offset? targetOffset = projectedPositions[link.target];

      if (sourceOffset != null && targetOffset != null) {
        // Connector link line: rgba(59, 130, 246, 0.35), width 2
        final Paint linkPaint = Paint()
          ..color = const Color(0x593B82F6)
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
          ..color = const Color(0xFF60A5FA)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(px, py), 4.0, packetPaint);
      }
    }

    // 5. Draw nodes
    for (final TopologyNode node in activeData.nodes) {
      final Offset? pos = projectedPositions[node.id];
      if (pos == null) continue;

      final bool isFocused = activeFocusedNode == node.id;
      final double vx =
          node.position.vector.isNotEmpty ? node.position.vector[0] : 0.0;
      final double vy =
          node.position.vector.length > 1 ? node.position.vector[1] : 0.0;

      // Red velocity vector line: rgba(239, 68, 68, 0.4), width 1.5
      final Paint vectorPaint = Paint()
        ..color = const Color(0x66EF4444)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          pos, Offset(pos.dx + vx * 2.0, pos.dy + vy * 2.0), vectorPaint);

      // Node base circle representation
      final Paint fillPaint = Paint()..style = PaintingStyle.fill;
      final Paint strokePaint = Paint()..style = PaintingStyle.stroke;
      final double radius = isFocused ? 12.0 : 9.0;

      if (isFocused) {
        fillPaint.color = const Color(0xFF3B82F6);
        strokePaint
          ..color = Colors.white
          ..strokeWidth = 2.5;
      } else {
        fillPaint.color = node.status == 'Active'
            ? const Color(0xFF10B981)
            : const Color(0xFFF59E0B);
        strokePaint
          ..color = const Color(0xFF1E293B)
          ..strokeWidth = 2.0;
      }

      canvas.drawCircle(pos, radius, fillPaint);
      canvas.drawCircle(pos, radius, strokePaint);

      // Pulsing halo ring around focused node (radius 20, stroke rgba(59, 130, 246, 0.3), width 1.5)
      if (isFocused) {
        final Paint haloPaint = Paint()
          ..color = const Color(0x4D3B82F6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(pos, 20.0, haloPaint);
      }

      // Draw node label below in white Color(0xFFF8FAFC)
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: node.label,
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 12.0,
            fontFamily: 'Outfit',
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
        oldDelegate.activeData != activeData;
  }
}
