import 'dart:math' as math;
import 'package:flutter/material.dart';

class ResizableSplitter extends StatefulWidget {
  final Widget leading;
  final Widget trailing;
  final Axis axis;
  final double initialRatio;
  final double minLeadingSize;
  final double minTrailingSize;
  final double dividerSize;
  final double gripWidth;
  final double gripHeight;

  const ResizableSplitter({
    super.key,
    required this.leading,
    required this.trailing,
    this.axis = Axis.vertical,
    this.initialRatio = 0.5,
    this.minLeadingSize = 150,
    this.minTrailingSize = 150,
    this.dividerSize = 8,
    this.gripWidth = 2,
    this.gripHeight = 40,
  });

  @override
  State<ResizableSplitter> createState() => _ResizableSplitterState();
}

class _ResizableSplitterState extends State<ResizableSplitter> {
  final ValueNotifier<double> _ratio = ValueNotifier<double>(0);
  bool _initialized = false;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) return;
      final total = widget.axis == Axis.horizontal
          ? box.size.width
          : box.size.height;
      if (total > 0) {
        _ratio.value = total * widget.initialRatio;
        _initialized = true;
        _total = total;
      }
    });
  }

  @override
  void dispose() {
    _ratio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = widget.axis == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        if (!_initialized && total > 0) {
          _ratio.value = total * widget.initialRatio;
          _initialized = true;
        }
        _total = total;

        final isHorizontal = widget.axis == Axis.horizontal;
        final dividerColor = Theme.of(context).dividerColor;
        final gripColor = Theme.of(context).iconTheme.color?.withAlpha(77) ?? dividerColor;

        final divider = GestureDetector(
          onPanUpdate: (d) {
            final delta = isHorizontal ? d.delta.dx : d.delta.dy;
            _ratio.value = (_ratio.value + delta).clamp(
              widget.minLeadingSize,
              math.max(widget.minLeadingSize, _total - widget.minTrailingSize),
            );
          },
          child: MouseRegion(
            cursor: isHorizontal
                ? SystemMouseCursors.resizeColumn
                : SystemMouseCursors.resizeRow,
            child: Container(
              width: isHorizontal ? widget.dividerSize : null,
              height: isHorizontal ? null : widget.dividerSize,
              decoration: BoxDecoration(
                color: dividerColor,
                border: isHorizontal
                    ? Border.symmetric(
                        vertical: BorderSide(color: dividerColor, width: 1))
                    : Border.symmetric(
                        horizontal: BorderSide(color: dividerColor, width: 1)),
              ),
              child: Center(
                child: Container(
                  width: isHorizontal ? widget.gripWidth : widget.gripHeight,
                  height: isHorizontal ? widget.gripHeight : widget.gripWidth,
                  color: gripColor,
                ),
              ),
            ),
          ),
        );

        final trailingPane = Expanded(child: RepaintBoundary(child: widget.trailing));

        final sizedLeading = ValueListenableBuilder<double>(
          valueListenable: _ratio,
          builder: (context, clamped, _) {
            return isHorizontal
                ? SizedBox(width: clamped, child: RepaintBoundary(child: widget.leading))
                : SizedBox(height: clamped, child: RepaintBoundary(child: widget.leading));
          },
        );

        if (isHorizontal) {
          return Row(children: [sizedLeading, divider, trailingPane]);
        }
        return Column(children: [sizedLeading, divider, trailingPane]);
      },
    );
  }
}
