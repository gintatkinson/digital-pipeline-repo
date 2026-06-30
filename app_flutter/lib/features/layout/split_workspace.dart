import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A resizable split pane that lays out [leading] and [trailing] widgets
/// along [direction] with a draggable divider.
///
/// The initial split ratio is set from [initialRatio] once the available size
/// is known. The first pane is clamped between [minFirstPaneSize] and
/// (`totalSize - minFirstPaneSize`). The divider shows a resize cursor and
/// fires [onDrag] with the current first-pane size during drag.
///
/// Edge cases: when constraints are zero (e.g. not yet laid out), the splitter
/// is not rendered. When total size is insufficient for both minimums, the
/// first pane takes its minimum and the trailing pane fills the remainder
/// (may be smaller than [minFirstPaneSize]).
  final Widget leading;
  final Widget trailing;
  final Axis direction;
  final double minFirstPaneSize;
  final double initialRatio;
  final Key? splitterKey;
  final ValueChanged<double>? onDrag;

  const SplitWorkspace({
    super.key,
    required this.leading,
    required this.trailing,
    required this.direction,
    required this.minFirstPaneSize,
    required this.initialRatio,
    this.splitterKey,
    this.onDrag,
  });

  @override
  State<SplitWorkspace> createState() => _SplitWorkspaceState();
}

class _SplitWorkspaceState extends State<SplitWorkspace> {
  double _firstPaneSize = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        if (!_initialized && totalSize > 0) {
          _firstPaneSize = totalSize * widget.initialRatio;
          _initialized = true;
        }

        final clampedFirstPane = _firstPaneSize.clamp(
          widget.minFirstPaneSize,
          math.max(widget.minFirstPaneSize, totalSize - widget.minFirstPaneSize),
        ).toDouble();

        final isHorizontal = widget.direction == Axis.horizontal;

        final splitter = GestureDetector(
          key: widget.splitterKey,
          onHorizontalDragUpdate: isHorizontal
              ? (details) {
                  setState(() {
                    _firstPaneSize = (_firstPaneSize + details.delta.dx)
                        .clamp(widget.minFirstPaneSize, math.max(widget.minFirstPaneSize, totalSize - widget.minFirstPaneSize)).toDouble();
                  });
                  widget.onDrag?.call(_firstPaneSize);
                }
              : null,
          onVerticalDragUpdate: !isHorizontal
              ? (details) {
                  setState(() {
                    _firstPaneSize = (_firstPaneSize + details.delta.dy)
                        .clamp(widget.minFirstPaneSize, math.max(widget.minFirstPaneSize, totalSize - widget.minFirstPaneSize)).toDouble();
                  });
                  widget.onDrag?.call(_firstPaneSize);
                }
              : null,
          child: MouseRegion(
            cursor: isHorizontal
                ? SystemMouseCursors.resizeLeftRight
                : SystemMouseCursors.resizeUpDown,
            child: Container(
              width: isHorizontal ? 8 : double.infinity,
              height: isHorizontal ? double.infinity : 8,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                border: isHorizontal
                    ? Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      )
                    : Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
              ),
              child: Center(
                child: Container(
                  width: isHorizontal ? 2 : 40,
                  height: isHorizontal ? 40 : 2,
                  color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.3) ??
                      Theme.of(context).dividerColor,
                ),
              ),
            ),
          ),
        );

        final leadingPane = isHorizontal
            ? SizedBox(width: clampedFirstPane, child: RepaintBoundary(child: widget.leading))
            : SizedBox(height: clampedFirstPane, child: RepaintBoundary(child: widget.leading));

        final trailingPane = Expanded(child: RepaintBoundary(child: widget.trailing));

        if (isHorizontal) {
          return Row(
            children: [leadingPane, splitter, trailingPane],
          );
        } else {
          return Column(
            children: [leadingPane, splitter, trailingPane],
          );
        }
      },
    );
  }
}
