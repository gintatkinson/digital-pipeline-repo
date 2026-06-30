import 'package:flutter/material.dart';

/// Describes a domain operation that can be invoked on a managed object.
///
/// Actions represent operations beyond CRUD — e.g., "reboot", "compute path",
/// "deploy configuration". They are discovered at runtime via
/// [DataSource.getActions] and rendered as buttons in [ActionPanel].
///
/// Each action carries metadata for UI rendering (label, icon), safety
/// (confirmation prompt, destructive flag), and parameter schema for
/// operations that require user input before invocation.
class ActionDescriptor {
  /// Machine-readable action name, e.g. "compute_path", "reboot".
  final String name;

  /// Human-readable label for the action button, e.g. "Compute Path".
  final String label;

  /// Material icon name for the action button, resolved via [IconMapper].
  final String iconName;

  /// Optional confirmation dialog text. When null and [destructive] is false,
  /// the action fires immediately on button tap without confirmation.
  final String? confirmation;

  /// Whether this action has destructive side effects. When true, the
  /// confirmation dialog includes an extra warning even if [confirmation]
  /// is null.
  final bool destructive;

  /// Optional parameters the action requires before invocation.
  final List<ActionParameterDescriptor>? parameters;

  const ActionDescriptor({
    required this.name,
    required this.label,
    required this.iconName,
    this.confirmation,
    this.destructive = false,
    this.parameters,
  });
}

/// Describes a single input parameter for an [ActionDescriptor].
///
/// Parameters are rendered as form fields in a dialog before the action
/// is invoked. The schema mirrors [FieldDescriptor] but is scoped to
/// action-specific inputs rather than persistent object attributes.
class ActionParameterDescriptor {
  /// Parameter key, used as the map key when invoking the action.
  final String key;

  /// Human-readable label for the input field.
  final String label;

  /// Data type: "string", "int", "double", "enum".
  final String type;

  /// Whether this parameter is required before invocation.
  final bool required;

  /// Default value when the parameter is optional and not supplied.
  final dynamic defaultValue;

  /// Allowed values for enum-type parameters.
  final List<String>? enumOptions;

  const ActionParameterDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.enumOptions,
  });
}
