import 'package:flutter/material.dart';
import 'package:app_flutter/domain/column_model.dart';

/// Base class for rendering a single table cell.
abstract class CellRenderer {
  /// Creates a [CellRenderer].
  const CellRenderer();

  /// Builds the widget for [value] in the context of [column].

  Widget build(BuildContext context, String value, ColumnModel column);
}

/// Renders plain text cells.
class TextRenderer extends CellRenderer {
  /// Creates a [TextRenderer].
  const TextRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    return Text(
      value,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

/// Renders numeric cells right-aligned with monospace font.
class NumericRenderer extends CellRenderer {
  /// Creates a [NumericRenderer].
  const NumericRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}

/// Renders enum cells inside a rounded chip.
class EnumRenderer extends CellRenderer {
  /// Creates an [EnumRenderer].
  const EnumRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Renders date cells in YYYY-MM-DD format.
class DateRenderer extends CellRenderer {
  /// Creates a [DateRenderer].
  const DateRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    final parsed = DateTime.tryParse(value);
    final display = parsed != null
        ? '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}'
        : value;
    return Text(
      display,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

/// Renders boolean cells as check/close icons.
class BooleanRenderer extends CellRenderer {
  const BooleanRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    final isTrue = value.toLowerCase() == 'true';
    return Icon(
      isTrue ? Icons.check : Icons.close,
      size: 16,
      color: isTrue ? Colors.green : Colors.red,
    );
  }
}

/// Renders reference cells underlined with primary color.
class ReferenceRenderer extends CellRenderer {
  const ReferenceRenderer();

  @override
  Widget build(BuildContext context, String value, ColumnModel column) {
    return Text(
      value,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
