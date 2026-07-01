import 'package:flutter/material.dart';
import 'package:app_flutter/domain/action_descriptor.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Renders a set of domain action buttons for a managed object.
///
/// Actions represent operations beyond CRUD — "reboot", "compute path",
/// "deploy configuration" — discovered at runtime via [DataSource.getActions].
/// Each button is enabled/disabled based on the object's [LifecycleState]
/// per the state-action availability matrix:
///
/// | State | Action Buttons |
/// |-------|---------------|
/// | discovered | All enabled |
/// | provisioning | All disabled |
/// | active | All enabled |
/// | degraded | All enabled |
/// | decommissioned | All disabled |
/// | failed | Non-destructive only |
/// | null (unknown) | All enabled (treat as active) |
///
/// Destructive actions show a confirmation dialog with an extra warning.
/// Actions with parameters show an input dialog before invocation.
/// Simple results are displayed as SnackBar; structured results as AlertDialog.
class ActionPanel extends StatelessWidget {
  /// Actions to render. Empty list renders nothing.
  final List<ActionDescriptor> actions;

  /// Current lifecycle state of the object. Null treated as [active].
  final LifecycleState? lifecycleState;

  /// Type name for the current object.
  final String typeName;

  /// Instance ID for the current object.
  final String nodeId;

  /// Invocation callback. Receives action name and parameter map.
  /// Returns a result map with at least 'success' (bool) and 'message' (String).
  final Future<Map<String, dynamic>> Function(
    String typeName,
    String nodeId,
    String actionName,
    Map<String, dynamic> parameters,
  ) onInvoke;

  /// Creates an [ActionPanel] with the given actions and configuration.
  const ActionPanel({
    super.key,
    required this.actions,
    this.lifecycleState,
    required this.typeName,
    required this.nodeId,
    required this.onInvoke,
  });

  /// Returns true if actions should be enabled for [state].
  bool _isActionEnabled(ActionDescriptor action) {
    final state = lifecycleState ?? LifecycleState.active;
    switch (state) {
      case LifecycleState.provisioning:
      case LifecycleState.decommissioned:
        return false;
      case LifecycleState.failed:
        return !action.destructive;
      case LifecycleState.discovered:
      case LifecycleState.active:
      case LifecycleState.degraded:
        return true;
    }
  }

  /// Builds a column with a divider, "Actions" title, and a [Wrap] of action
  /// buttons. Returns [SizedBox.shrink] when [actions] is empty so that the
  /// panel contributes no visual space. Each button's enabled state follows
  /// [_isActionEnabled] per the state-action availability matrix.
  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Actions', style: Theme.of(context).textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) => _ActionButton(
              action: action,
              enabled: _isActionEnabled(action),
              onInvoke: () => _handleActionTap(context, action),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _handleActionTap(BuildContext context, ActionDescriptor action) async {
    if (action.destructive || action.confirmation != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(action.label),
          content: Text([
            if (action.confirmation != null) action.confirmation!,
            if (action.destructive)
              '\n\nThis action may have side effects. Proceed with caution.',
          ].join()),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    Map<String, dynamic> params = {};
    if (action.parameters != null && action.parameters!.isNotEmpty) {
      params = await _showParameterDialog(context, action);
      if (params.isEmpty) return;
    }

    try {
      final result = await onInvoke(typeName, nodeId, action.name, params);
      if (!context.mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((result['message'] as String?) ?? '${action.label} completed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((result['message'] as String?) ?? '${action.label} failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${action.label} failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _showParameterDialog(
    BuildContext context,
    ActionDescriptor action,
  ) async {
    final controllers = <String, TextEditingController>{};
    final params = action.parameters!;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${action.label} Parameters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: params.map((param) {
                final controller = TextEditingController(
                  text: param.defaultValue?.toString() ?? '',
                );
                controllers[param.key] = controller;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: param.label,
                      helperText: param.required ? 'Required' : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final map = <String, dynamic>{};
                for (final param in params) {
                  final value = controllers[param.key]?.text ?? '';
                  if (value.isNotEmpty) {
                    map[param.key] = value;
                  }
                }
                Navigator.of(ctx).pop(map);
              },
              child: const Text('Invoke'),
            ),
          ],
        );
      },
    );

    for (final c in controllers.values) {
      c.dispose();
    }

    return result ?? <String, dynamic>{};
  }
}

class _ActionButton extends StatelessWidget {
  final ActionDescriptor action;
  final bool enabled;
  final VoidCallback onInvoke;

  const _ActionButton({
    required this.action,
    required this.enabled,
    required this.onInvoke,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onInvoke : null,
      child: Text(action.label),
    );
  }
}
