import 'package:flutter/material.dart';
import 'package:pipeline_app/features/detail/topology_view_model.dart';
import 'package:pipeline_app/features/layout/breadcrumbs.dart';

/// Topology canvas with interactive node rendering.
///
/// The header shows the active view label and breadcrumbs. The canvas
/// draws positioned nodes with labels and directional links. Tapping a
/// node selects it via [onNodeSelected]. A loading indicator is shown
/// while the topology data is initialising.
class TopologyView extends StatefulWidget {
  final TopologyViewModel viewModel;
  final ValueChanged<String> onNodeSelected;
  final List<BreadcrumbItem> breadcrumbs;

  const TopologyView({
    super.key,
    required this.viewModel,
    required this.onNodeSelected,
    this.breadcrumbs = const [],
  });

  @override
  State<TopologyView> createState() => _TopologyViewState();
}

class _TopologyViewState extends State<TopologyView> {
  final GlobalKey _canvasKey = GlobalKey();

  void _handleTap(Offset position) {
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final local = renderBox.globalToLocal(position);
    const hitRadius = 12.0;
    for (final node in widget.viewModel.nodes) {
      final dx = local.dx - node.d0;
      final dy = local.dy - node.d1;
      if (dx * dx + dy * dy <= hitRadius * hitRadius) {
        widget.onNodeSelected(node.id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final nodes = widget.viewModel.nodes;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Active View: ${widget.viewModel.selectedNodeId ?? ""}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (widget.breadcrumbs.isNotEmpty)
                    NavigationBreadcrumbs(items: widget.breadcrumbs),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: nodes.isEmpty
                  ? const Center(child: Text('Loading...'))
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) => _handleTap(details.globalPosition),
                      child: CustomPaint(
                        key: _canvasKey,
                        painter: _TopologyPainter(
                          nodes: nodes,
                          links: widget.viewModel.links,
                          selectedNodeId: widget.viewModel.selectedNodeId,
                          color: cs.primary,
                          onSurface: cs.onSurface,
                          surface: cs.surfaceContainerHighest,
                        ),
                        size: Size.infinite,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TopologyPainter extends CustomPainter {
  final List<TopologyNode> nodes;
  final List<TopologyLink> links;
  final String? selectedNodeId;
  final Color color;
  final Color onSurface;
  final Color surface;

  _TopologyPainter({
    required this.nodes,
    required this.links,
    required this.selectedNodeId,
    required this.color,
    required this.onSurface,
    required this.surface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final link in links) {
      final from = nodeMap[link.fromId];
      final to = nodeMap[link.toId];
      if (from != null && to != null) {
        canvas.drawLine(
          Offset(from.d0, from.d1),
          Offset(to.d0, to.d1),
          Paint()..color = color.withAlpha(50)..strokeWidth = 1,
        );
      }
    }

    for (final node in nodes) {
      final isSelected = node.id == selectedNodeId;
      final radius = isSelected ? 6.0 : 4.0;
      final fillColor = isSelected ? color : color.withAlpha(160);

      canvas.drawCircle(
        Offset(node.d0, node.d1),
        radius + 1,
        Paint()..color = surface..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(node.d0, node.d1),
        radius,
        Paint()..color = fillColor..style = PaintingStyle.fill,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: node.id,
          style: TextStyle(
            color: onSurface,
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 100);

      tp.paint(canvas, Offset(node.d0 - tp.width / 2, node.d1 + 8));
    }
  }

  @override
  bool shouldRepaint(_TopologyPainter old) =>
      old.nodes != nodes ||
      old.links != links ||
      old.selectedNodeId != selectedNodeId ||
      old.onSurface != onSurface;
}
