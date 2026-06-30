import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Converts all input characters to uppercase in a text field.
///
/// Exists to enforce a consistent uppercase display format for fields whose
/// [FieldDescriptor.inputFormatters] contains the `"uppercase"` literal. Use
/// this when the data source expects uppercase identifiers (e.g., asset codes,
/// serial numbers).
///
/// Edge cases: operates on every keystroke via [TextEditingValue]; an empty
/// string remains empty. Non-letter characters are unaffected.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Editable property grid that displays [FieldDescriptor] fields grouped by
/// section and emits validated data on blur.
///
/// Exists to provide a generic, schema-driven form for editing typed objects
/// whose structure is not known at compile time (e.g., nodes from an external
/// data source). Use this widget whenever you need inline editing of structured
/// properties with validation, enum dropdowns, and blur-based commit.
///
/// Edge cases:
///   - An empty [fields] list renders a no-op grid with nothing to edit.
///   - [initialValues] may omit keys present in [fields]; those fields start
///     with an empty string.
///   - Validation errors for each field are displayed inline below the input;
///     they are cleared when the field passes validation on blur.
///
/// State changes: committed data is accumulated in `committedData` and emitted
/// via [onSave] on each successful blur. This widget does NOT start any
/// long-lived streams or timers. All controllers and focus nodes are disposed
/// in [dispose].
class PropertyGrid extends StatefulWidget {
  /// The list of field descriptors to display. When empty the grid renders
  /// nothing editable.
  final List<FieldDescriptor> fields;

  /// Initial values keyed by [FieldDescriptor.key]. Keys present in
  /// [initialValues] but absent from [fields] are silently ignored. Missing
  /// keys render as empty strings.
  final Map<String, dynamic> initialValues;

  /// Called with the current committed data after a field passes validation on
  /// blur. Not called if validation fails. The callback receives a fresh
  /// `Map<String, dynamic>` of the entire committed state, not just the edited
  /// field. Can be null to opt out of save notifications.
  final void Function(Map<String, dynamic>)? onSave;

  /// The currently active view name used to highlight the matching section.
  /// When set to `'root'`, the first section (alphabetically) is highlighted.
  /// Sections whose [FieldDescriptor.sectionLabel] does not match are dimmed.
  final String activeView;

  const PropertyGrid({
    super.key,
    this.fields = const [],
    this.initialValues = const {},
    this.onSave,
    this.activeView = 'root',
  });

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

const _wideLayoutBreakpoint = 700.0;
const _inactiveSectionOpacity = 0.65;
const _activeShadowOpacity = 0.1;
const _inactiveShadowOpacity = 0.05;
const _activeBadgeBgOpacity = 0.15;
const _activeBadgeBorderOpacity = 0.3;

class _PropertyGridState extends State<PropertyGrid> {
  late List<FieldDescriptor> _fields;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  Map<String, String> _errors = const {};
  final Map<String, bool> _hadFocus = {};

  late Map<String, dynamic> committedData;

  @override
  void initState() {
    super.initState();
    _fields = widget.fields;
    committedData = Map<String, dynamic>.from(widget.initialValues);
    _initializeFields(_fields, committedData);
  }

  void _initializeFields(List<FieldDescriptor> fields, Map<String, dynamic> nodeData) {
    for (final field in fields) {
      final val = nodeData[field.key];
      final text = val != null ? val.toString() : '';
      final controller = TextEditingController(text: text);
      final focusNode = FocusNode();

      _controllers[field.key] = controller;
      _focusNodes[field.key] = focusNode;
      _hadFocus[field.key] = false;

      if (field.type != 'enum') {
        focusNode.addListener(() {
          final bool currentlyHasFocus = focusNode.hasFocus;
          final bool previouslyHadFocus = _hadFocus[field.key] ?? false;
          _hadFocus[field.key] = currentlyHasFocus;

          if (previouslyHadFocus && !currentlyHasFocus) {
            _triggerBlurSave(field.key, field);
          }
        });
      }
    }
  }

  void _disposeAllFields() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
    _hadFocus.clear();
    _errors = const {};
  }

  @override
  void didUpdateWidget(PropertyGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldFields = oldWidget.fields;
    final newFields = widget.fields;

    bool fieldsChanged = oldFields.length != newFields.length;
    if (!fieldsChanged) {
      for (int i = 0; i < newFields.length; i++) {
        if (oldFields[i].key != newFields[i].key ||
            oldFields[i].type != newFields[i].type ||
            oldFields[i].sectionLabel != newFields[i].sectionLabel) {
          fieldsChanged = true;
          break;
        }
      }
    }

    if (fieldsChanged) {
      setState(() {
        _disposeAllFields();
        _fields = newFields;
        committedData = Map<String, dynamic>.from(widget.initialValues);
        _initializeFields(_fields, committedData);
      });
    } else {
      setState(() {
        committedData = Map<String, dynamic>.from(widget.initialValues);
        _errors = const {};
        for (final field in _fields) {
          final focusNode = _focusNodes[field.key];
          if (focusNode != null && !focusNode.hasFocus) {
            final newVal = widget.initialValues[field.key] ?? committedData[field.key];
            final text = newVal != null ? newVal.toString() : '';
            _controllers[field.key]?.text = text;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _disposeAllFields();
    super.dispose();
  }

  (bool isValid, dynamic parsedValue, String? error) _validateField(
    String key, FieldDescriptor field, String valueString,
  ) {
    dynamic parsedValue;

    if (field.required && valueString.trim().isEmpty) {
      return (false, null, '${field.label} is required');
    }

    if (field.type == 'double') {
      final val = double.tryParse(valueString);
      if (val == null && valueString.isNotEmpty) {
        return (false, null, 'Must be a valid double');
      }
      parsedValue = val;
    } else if (field.type == 'int') {
      final val = int.tryParse(valueString);
      if (val == null && valueString.isNotEmpty) {
        return (false, null, 'Must be a valid integer');
      }
      parsedValue = val;
    } else {
      parsedValue = valueString;
    }

    if (field.pattern != null && valueString.isNotEmpty) {
      final reg = RegExp(field.pattern!);
      if (!reg.hasMatch(valueString)) {
        return (false, parsedValue, 'Invalid format');
      }
    }

    if (parsedValue is num) {
      if (field.minValue != null && parsedValue < field.minValue!) {
        return (false, parsedValue, 'Value cannot be less than ${field.minValue}');
      }
      if (field.maxValue != null && parsedValue > field.maxValue!) {
        return (false, parsedValue, 'Value cannot be greater than ${field.maxValue}');
      }
    }

    return (true, parsedValue, null);
  }

  void _triggerBlurSave(String key, FieldDescriptor field) {
    final valueString = field.type == 'enum'
        ? (committedData[key]?.toString() ?? '')
        : (_controllers[key]?.text ?? '');
    final Map<String, String> newErrors = Map<String, String>.from(_errors);

    final (bool isValid, dynamic parsedValue, String? error) = _validateField(key, field, valueString);

    setState(() {
      if (isValid) {
        newErrors.remove(key);
      } else {
        newErrors[key] = error ?? 'Invalid value';
      }
      _errors = newErrors;
    });

    if (isValid) {
      setState(() {
        committedData[key] = parsedValue;
      });

      widget.onSave?.call(Map<String, dynamic>.from(committedData));
    }
  }

  List<TextInputFormatter>? _resolveInputFormatters(FieldDescriptor field) {
    if (field.inputFormatters == null || field.inputFormatters!.isEmpty) return null;
    final List<TextInputFormatter> formatters = [];
    for (final fmt in field.inputFormatters!) {
      if (fmt == 'uppercase') {
        formatters.add(UpperCaseTextFormatter());
      } else if (fmt.startsWith('maxLength:')) {
        final parts = fmt.split(':');
        if (parts.length == 2) {
          final len = int.tryParse(parts[1]);
          if (len != null) {
            formatters.add(LengthLimitingTextInputFormatter(len));
          }
        }
      }
    }
    return formatters.isNotEmpty ? formatters : null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final groups = <String>{};
    for (final field in _fields) {
      groups.add(field.sectionLabel ?? 'Other');
    }

    final List<String> sortedGroups = groups.toList();
    sortedGroups.sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = constraints.maxWidth > _wideLayoutBreakpoint
                  ? (constraints.maxWidth - 16.0) / 2.0
                  : constraints.maxWidth;

              final List<Widget> sections = sortedGroups.map((group) {
                final bool isActive = group == widget.activeView ||
                    (widget.activeView == 'root' && group == sortedGroups.first);

                return _buildSystemSection(
                  title: group,
                  isActive: isActive,
                  isDark: isDark,
                  width: cardWidth,
                  child: _buildGroupFields(group, isDark),
                );
              }).toList();

              if (constraints.maxWidth > _wideLayoutBreakpoint && sections.length >= 2) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sections[0],
                    const SizedBox(width: 8),
                    sections[1],
                  ],
                );
              } else {
                final List<Widget> columnChildren = [];
                for (int i = 0; i < sections.length; i++) {
                  columnChildren.add(sections[i]);
                  if (i < sections.length - 1) {
                    columnChildren.add(const SizedBox(height: 8));
                  }
                }
                return Column(children: columnChildren);
              }
            },
          ),
          const SizedBox(height: 8),
          _buildCommittedStatePanel(isDark),
        ],
      ),
    );
  }

  Widget _buildSystemSection({
    required String title,
    required bool isActive,
    required bool isDark,
    required double width,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    final Color brandPrimary = cs.primary;
    final Color borderColor = Theme.of(context).dividerColor;
    final Color surfaceFill = cs.surfaceContainerHighest;
    final Color borderActive = brandPrimary;

    return Opacity(
      opacity: isActive ? 1.0 : _inactiveSectionOpacity,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: surfaceFill,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isActive ? borderActive : borderColor,
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: brandPrimary.withValues(alpha: _activeShadowOpacity),
                    blurRadius: 24.0,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: _inactiveShadowOpacity),
                    blurRadius: 20.0,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: _activeBadgeBgOpacity),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: _activeBadgeBorderOpacity),
                        ),
                      ),
                      child: Text(
                        'Active Reference',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGroupFields(String group, bool isDark) {
    final groupFields = _fields
        .where((field) => (field.sectionLabel ?? 'Other') == group)
        .toList()
      ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));

    final List<Widget> fields = [];
    for (final field in groupFields) {
      fields.add(_buildAttrField(field, isDark));
      fields.add(const SizedBox(height: 8));
    }

    if (fields.isNotEmpty) {
      fields.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  Widget _buildAttrField(FieldDescriptor field, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final Color brandPrimary = cs.primary;

    if (field.type == 'enum') {
      final options = field.enumOptions ?? const [];
      final currentValue = committedData[field.key] ?? (options.isNotEmpty ? options.first : '');

      return _buildDropdownField(
        label: field.label,
        focusNode: _focusNodes[field.key]!,
        value: currentValue as String,
        errorText: _errors[field.key],
        isDark: isDark,
        brandPrimary: brandPrimary,
        items: options.asMap().entries.map((entry) {
          final int idx = entry.key;
          final String opt = entry.value;
          String displayName = opt;
          if (field.enumDisplayNames != null && idx < field.enumDisplayNames!.length) {
            displayName = field.enumDisplayNames![idx];
          }
          return DropdownMenuItem<String>(
            value: opt,
            child: Text(displayName),
          );
        }).toList(),
        onChanged: (String? val) {
          if (val != null) {
            setState(() {
              committedData[field.key] = val;
            });
            _triggerBlurSave(field.key, field);
          }
        },
      );
    } else {
      TextInputType keyboardType = TextInputType.text;
      List<TextInputFormatter>? inputFormatters;

      if (field.type == 'double') {
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
      } else if (field.type == 'int') {
        keyboardType = TextInputType.number;
      }

      inputFormatters = _resolveInputFormatters(field);

      return _buildTextField(
        label: field.label,
        controller: _controllers[field.key]!,
        focusNode: _focusNodes[field.key]!,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        errorText: _errors[field.key],
        brandPrimary: brandPrimary,
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    required Color brandPrimary,
    ValueChanged<String>? onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            filled: true,
            fillColor: cs.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(
                color: errorText != null ? Theme.of(context).colorScheme.error : brandPrimary,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required FocusNode focusNode,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
    required bool isDark,
    required Color brandPrimary,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
          Focus(
            focusNode: focusNode,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: value,
            dropdownColor: isDark ? cs.surfaceContainerHighest : cs.surface,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              filled: true,
              fillColor: cs.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: errorText != null ? Theme.of(context).colorScheme.error : brandPrimary,
                  width: 1.5,
                ),
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildCommittedStatePanel(bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Committed Data (verified on blur)',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                const JsonEncoder.withIndent('  ').convert(committedData),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
