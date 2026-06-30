import 'package:flutter/material.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Displays the [LifecycleState] of a managed object as a color-coded badge.
///
/// Colors per state per docs/architecture/runtime-metadata-blueprint.md §9:
/// | State | Color |
/// |-------|-------|
/// | discovered | grey |
/// | provisioning | amber |
/// | active | green |
/// | degraded | orange |
/// | decommissioned | grey |
/// | failed | red |
///
/// When [state] is null, the widget renders nothing (empty SizedBox).
class StateIndicator extends StatelessWidget {
  final LifecycleState? state;

  const StateIndicator({super.key, this.state});

  Color _colorForState(BuildContext context) {
    switch (state) {
      case LifecycleState.discovered:
      case LifecycleState.decommissioned:
        return Colors.grey;
      case LifecycleState.provisioning:
        return Colors.amber;
      case LifecycleState.active:
        return Colors.green;
      case LifecycleState.degraded:
        return Colors.orange;
      case LifecycleState.failed:
        return Colors.red;
      case null:
        return Colors.transparent;
    }
  }

  String _labelForState() {
    if (state == null) return '';
    return state!.name[0].toUpperCase() + state!.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (state == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _colorForState(context).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorForState(context).withValues(alpha: 0.5)),
      ),
      child: Text(
        _labelForState(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _colorForState(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
