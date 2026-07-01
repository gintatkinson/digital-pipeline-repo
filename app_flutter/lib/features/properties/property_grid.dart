import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Callback invoked when a reference field (refType != null) is tapped.
/// Receives the refType and the field value (the referenced instance ID).
typedef ViewSelectedCallback = void Function(String refType, String id);

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
/// section with explicit Save/Cancel semantics and per-field dirty tracking.
///
/// Exists to provide a generic, schema-driven form for editing typed objects
/// whose structure is not known at compile time (e.g., nodes from an external
/// data source). Use this widget whenever you need inline editing of structured
/// properties with validation, enum dropdowns, and explicit save semantics.
///
/// ## Dirty-state model
///   - Every edit is tracked locally per field. A small circular indicator
///     (the "dirty dot") appears next to each field label whose current value
///     differs from the last committed state.
///   - The Save button commits only dirty fields in a single [onSave] call.
///     The Cancel button discards all uncommitted edits and resets every field
///     to its last committed value.
///   - [onDirtyChanged] fires on each dirty-state transition so parent widgets
///     (e.g., page-level navigation guards) can react to unsaved edits.
///
/// ## Navigation guard
///   - [PopScope] intercepts back navigation when [isDirty] is true and shows
///     a confirmation dialog. Discarding confirms the pop after resetting
///     fields via [_executeCancel].
///
/// Configuration options:
///   - [wideLayoutBreakpoint] controls the responsive breakpoint at which the
///     grid switches from single-column to two-column layout.
///   - [sectionPadding], [gapSize], [cardBorderRadius], and
///     [inputBorderRadius] let you tune the visual appearance of section cards
///     and input fields without rebuilding the widget tree.
///
/// Edge cases:
///   - An empty [fields] list renders a no-op grid with nothing to edit.
///   - [initialValues] may omit keys present in [fields]; those fields start
///     with an empty string.
///   - Validation errors for each field are displayed inline below the input;
///     they are cleared when the field passes validation.
///
/// State changes: each field is validated on blur, but [onSave] is fired
/// **only** when the user taps the Save button. The payload contains only the
/// subset of fields whose current value differs from [committedData]. This
/// widget does NOT start any long-lived streams or timers. All controllers and
/// focus nodes are disposed in [dispose].
class PropertyGrid extends StatefulWidget {
  /// The list of field descriptors to display. When empty the grid renders
  /// nothing editable.
  final List<FieldDescriptor> fields;

  /// Initial values keyed by [FieldDescriptor.key]. Keys present in
  /// [initialValues] but absent from [fields] are silently ignored. Missing
  /// keys render as empty strings.
  final Map<String, dynamic> initialValues;

  /// Called with a map of only the dirty fields when the user taps the Save
  /// button. Not called during validation or on blur. The payload is a
  /// `Map<String, dynamic>` containing only those [FieldDescriptor.key] entries
  /// whose current value differs from [committedData]. Can be null to opt out
  /// of save notifications.
  final Future<void> Function(Map<String, dynamic> data)? onSave;

  /// Called whenever the dirty state transitions.
  ///
  /// Fires with `true` when the first field becomes dirty, `false` when
  /// all fields are saved or cancelled. Allows parent widgets (e.g., Layout)
  /// to track dirty state for navigation guards.
  final ValueChanged<bool>? onDirtyChanged;

  /// The currently active view name used to highlight the matching section.
  /// When set to `'root'`, the first section (alphabetically) is highlighted.
  /// Sections whose [FieldDescriptor.sectionLabel] does not match are dimmed.
  final String activeView;

  /// Responsive breakpoint at which the layout switches from single-column to
  /// two-column grid. Defaults to 700.0.
  final double wideLayoutBreakpoint;

  /// Padding applied inside each section card. Defaults to
  /// `EdgeInsets.all(20.0)`.
  final EdgeInsetsGeometry sectionPadding;

  /// Uniform gap used between fields and sections. Defaults to 8.0.
  final double gapSize;

  /// Border radius used for section cards. Defaults to
  /// `BorderRadius.circular(12.0)`.
  final BorderRadiusGeometry cardBorderRadius;

  /// Border radius used for text field and dropdown input borders. Defaults to
  /// `BorderRadius.circular(6.0)`.
  final BorderRadius inputBorderRadius;

  /// When true, all fields are displayed as read-only (disabled text fields,
  /// disabled dropdowns, no Save/Cancel bar). Useful for degraded, failed,
  /// or decommissioned objects where editing is not permitted.
  final bool readOnly;

  /// Callback invoked when a reference field (refType != null) is tapped.
  /// Receives the refType and the field value (the referenced instance ID).
  final ViewSelectedCallback? onViewSelected;

  /// Creates a [PropertyGrid] with the given field descriptors, initial values,
  /// and visual configuration.
  ///
  /// All visual parameters have sensible defaults so that a basic grid works
  /// out of the box. Override them to match a specific design system:
  ///
  ///   - [wideLayoutBreakpoint] — when the available width exceeds this value,
  ///     the first two sections render side-by-side; below it they stack.
  ///   - [sectionPadding] — whitespace inside each section's card container.
  ///   - [gapSize] — vertical spacing between fields and sections.
  ///   - [cardBorderRadius] — corner rounding for section cards.
  ///   - [inputBorderRadius] — corner rounding for text field and dropdown
  ///     input borders.
  const PropertyGrid({
    super.key,
    this.fields = const [],
    this.initialValues = const {},
    this.onSave,
    this.onDirtyChanged,
    this.activeView = 'root',
    this.wideLayoutBreakpoint = 700.0,
    this.sectionPadding = const EdgeInsets.all(20.0),
    this.gapSize = 8.0,
    this.cardBorderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(6.0)),
    this.readOnly = false,
    this.onViewSelected,
  });

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

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
  late Map<String, String> _editingEnumValues;

  /// Tracks the last notified dirty state to detect transitions for
  /// [widget.onDirtyChanged].
  bool _previousDirty = false;

  /// When `true`, the [PopScope] guard is bypassed so the route can pop
  /// after the user has confirmed discarding unsaved edits.
  bool _popWhenReady = false;

  /// Whether any field has been edited but not yet saved.
  ///
  /// Compares the current controller text against the last committed value
  /// for text fields, and [_editingEnumValues] against [committedData] for
  /// enum fields. Returns `false` when all fields match their committed
  /// state, or when the widget has no fields.
  bool get isDirty {
    for (final f in widget.fields) {
      if (_isFieldDirty(f)) return true;
    }
    return false;
  }

  /// Fires [widget.onDirtyChanged] when [isDirty] transitions since the last
  /// call. No-op when the value is unchanged or no callback is registered.
  ///
  /// Calls [setState] so that any widget in the build tree that depends on
  /// [isDirty] (e.g., [PopScope.canPop]) is rebuilt with the new value.
  void _notifyDirtyIfChanged() {
    final dirty = isDirty;
    if (dirty != _previousDirty) {
      _previousDirty = dirty;
      setState(() {});
      widget.onDirtyChanged?.call(dirty);
    }
  }

  /// Returns `true` if [field]'s current editing value differs from its
  /// last committed value.
  ///
  /// For text-based fields (string, int, double, etc.), the comparison uses
  /// [TextEditingController.text]. For enum fields, the comparison uses
  /// [_editingEnumValues]. An uninitialized controller or missing enum entry
  /// is treated as an empty string, so this getter is safe to call even
  /// before the field has been rendered.
  bool _isFieldDirty(FieldDescriptor field) {
    final committed = committedData[field.key]?.toString() ?? '';
    if (field.type == 'enum') {
      return (_editingEnumValues[field.key]?.toString() ?? '') != committed;
    }
    return (_controllers[field.key]?.text ?? '') != committed;
  }

  /// Initializes [_editingEnumValues] from [committedData] for all enum
  /// fields declared on the widget. Safe to call multiple times — any
  /// previous entries are replaced.
  ///
  /// When [committedData] has no value for an enum field (null), the first
  /// option from [FieldDescriptor.enumOptions] is used as the default so
  /// that the dropdown is never in an invalid empty state.
  void _initEditingEnumValues() {
    _editingEnumValues = Map.fromEntries(
      widget.fields.where((f) => f.type == 'enum').map((f) {
        final options = f.enumOptions ?? <String>[];
        final committed = committedData[f.key]?.toString() ?? '';
        return MapEntry(
          f.key,
          committed.isNotEmpty ? committed : (options.isNotEmpty ? options.first : ''),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _fields = widget.fields;
    committedData = Map<String, dynamic>.from(widget.initialValues);
    _initEditingEnumValues();
    _initializeFields(_fields, committedData);
    _previousDirty = false;
    _popWhenReady = false;
  }

  /// Creates a [TextEditingController] and [FocusNode] for every field in
  /// [fields], seeding each controller with the value from [nodeData].
  ///
  /// Enum fields do not receive a focus listener because their value is
  /// committed immediately on selection change rather than on blur.
  void _initializeFields(List<FieldDescriptor> fields, Map<String, dynamic> nodeData) {
    for (final field in fields) {
      final val = nodeData[field.key];
      final text = val != null ? val.toString() : '';
      final controller = TextEditingController(text: text);
      final focusNode = FocusNode();

      controller.addListener(_notifyDirtyIfChanged);

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

  /// Disposes all [TextEditingController] and [FocusNode] instances, then
  /// clears internal maps and resets the error state.
  ///
  /// Called from [dispose] and from [didUpdateWidget] when the field list
  /// changes. After this method returns the widget is left in a clean state
  /// ready for [_initializeFields] to re-create everything.
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
        _initEditingEnumValues();
        _initializeFields(_fields, committedData);
      });
    } else {
      setState(() {
        committedData = Map<String, dynamic>.from(widget.initialValues);
        _initEditingEnumValues();
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

  /// Validates a field's string value according to the rules declared on
  /// [field].
  ///
  /// Returns a tuple of (isValid, parsedValue, errorMessage):
  ///   - [isValid] is true when all checks pass.
  ///   - [parsedValue] is the value coerced to `double`, `int`, or kept as
  ///     `String` depending on [field.type].
  ///   - [error] is a human-readable message when validation fails, or null
  ///     on success.
  ///
  /// Checks performed in order: required (non-empty), numeric parse,
  /// regex pattern, numeric bounds. Validation is skipped entirely when
  /// [valueString] is empty and the field is not required, allowing optional
  /// fields to remain blank.
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

  /// Validates the current value of [field] on blur and, if valid, commits it
  /// to [committedData].
  ///
  /// For enum fields the value is read from [_editingEnumValues] (updated by
  /// the dropdown's onChanged before this method is called); for all other
  /// types it is read from the associated [TextEditingController].
  ///
  /// On validation failure the error message is stored in [_errors] and
  /// displayed inline below the input. This method does NOT fire
  /// [widget.onSave] — saves are exclusively triggered via the Save button
  /// through [_executeSave].
  void _triggerBlurSave(String key, FieldDescriptor field) {
    final valueString = field.type == 'enum'
        ? (_editingEnumValues[key]?.toString() ?? '')
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
      // Validation passed — error is cleared but committedData is NOT updated
      // here. The committed data (and thus dirty tracking) is only advanced on
      // explicit Save via [_executeSave] or Cancel via [_executeCancel].
    }
  }

  /// Commits all dirty fields to the DataSource in a single atomic call.
  ///
  /// Collects only fields whose current value differs from the last committed
  /// state, passes them to [widget.onSave], then updates [committedData] on
  /// success. Displays validation errors and aborts if any field is invalid.
  ///
  /// This is the ONLY path that fires [widget.onSave] — blur events no longer
  /// trigger saves.
  Future<void> _executeSave() async {
    final validated = <String, dynamic>{};

    for (final f in widget.fields) {
      final valueString = f.type == 'enum'
          ? (_editingEnumValues[f.key]?.toString() ?? '')
          : (_controllers[f.key]?.text ?? '');
      final (isValid, parsedValue, error) = _validateField(f.key, f, valueString);
      if (!isValid) {
        setState(() => _errors = {f.key: error ?? 'Invalid value'});
        return;
      }
      validated[f.key] = parsedValue;
    }

    setState(() => _errors = const {});

    final dirty = <String, dynamic>{};
    for (final f in widget.fields) {
      if (_isFieldDirty(f)) {
        dirty[f.key] = validated[f.key];
      }
    }

    if (dirty.isEmpty) return;

    await widget.onSave?.call(dirty);

    setState(() {
      for (final key in dirty.keys) {
        committedData[key] = dirty[key];
      }
    });
    _notifyDirtyIfChanged();
  }

  /// Discards all uncommitted edits and resets every field to its last
  /// committed value. Does NOT fire [widget.onSave] — no data is written.
  void _executeCancel() {
    setState(() {
      _errors = const {};
      for (final f in widget.fields) {
        final committed = committedData[f.key]?.toString() ?? '';
        if (f.type == 'enum') {
          _editingEnumValues[f.key] = committed;
        } else {
          _controllers[f.key]?.text = committed;
        }
      }
    });
    _notifyDirtyIfChanged();
  }

  /// Resolves the list of [TextInputFormatter]s declared on [field].
  ///
  /// Supported [FieldDescriptor.inputFormatters] directives:
  ///   - `"uppercase"` — applies [UpperCaseTextFormatter].
  ///   - `"maxLength:N"` — applies [LengthLimitingTextInputFormatter] with
  ///     limit N.
  ///
  /// Returns null when no formatters are configured, which allows callers to
  /// pass null directly to the [TextField.inputFormatters] parameter.
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

    return PopScope(
      canPop: !isDirty || _popWhenReady,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (isDirty) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Unsaved changes'),
              content: const Text('Discard unsaved changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            _executeCancel();
            _popWhenReady = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = constraints.maxWidth > widget.wideLayoutBreakpoint
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

              if (constraints.maxWidth > widget.wideLayoutBreakpoint && sections.length >= 2) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sections[0],
                    SizedBox(width: widget.gapSize),
                    sections[1],
                  ],
                );
              } else {
                final List<Widget> columnChildren = [];
                for (int i = 0; i < sections.length; i++) {
                  columnChildren.add(sections[i]);
                  if (i < sections.length - 1) {
                    columnChildren.add(SizedBox(height: widget.gapSize));
                  }
                }
                return Column(children: columnChildren);
              }
            },
          ),
          SizedBox(height: widget.gapSize),
          _buildCommittedStatePanel(isDark),
          // Save/Cancel buttons — visible only when at least one field has
          // uncommitted edits (isDirty). The Save button is the sole path that
          // fires [widget.onSave]; the Cancel button resets all fields to their
          // last committed values with no RPC call.
          if (!widget.readOnly && isDirty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _executeCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _executeSave,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    );
  }

  /// Builds a single section card with a title header, an optional "Active
  /// Reference" badge, and the field content.
  ///
  /// The [isActive] flag controls opacity, border width, border color, and
  /// shadow intensity. Active sections use [widget.cardBorderRadius] and the
  /// primary brand color for their border and shadow; inactive sections are
  /// dimmed with a subtler shadow and a neutral border.
  ///
  /// The [width] parameter is applied to the outer container so that sections
  /// can be laid out side-by-side by the caller.
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
        padding: widget.sectionPadding,
        decoration: BoxDecoration(
          color: surfaceFill,
          borderRadius: widget.cardBorderRadius,
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
            SizedBox(height: widget.gapSize),
            child,
          ],
        ),
      ),
    );
  }

  /// Builds all fields belonging to [group], sorted by [FieldDescriptor.sectionOrder].
  ///
  /// Each field is separated by [widget.gapSize] of vertical space. An empty
  /// group renders an empty [Column] with no visible output.
  Widget _buildGroupFields(String group, bool isDark) {
    final groupFields = _fields
        .where((field) => (field.sectionLabel ?? 'Other') == group)
        .toList()
      ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));

    final List<Widget> fields = [];
    for (final field in groupFields) {
      fields.add(_buildAttrField(field, isDark));
      fields.add(SizedBox(height: widget.gapSize));
    }

    if (fields.isNotEmpty) {
      fields.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  /// Builds the input widget for a single [field], dispatching to either a
  /// dropdown (for `enum` fields) or a text field (for all other types).
  ///
  /// The dispatched type is determined by [FieldDescriptor.type]. Numeric
  /// fields (`double`, `int`) receive the appropriate keyboard type.
  /// The current error state, if any, is passed down from [_errors].
  ///
  /// Edge cases: enum fields with no options render an empty dropdown with
  /// the first available option implicitly selected; missing enum options or
  /// missing display names are handled gracefully (falling back to the raw
  /// value or index).
  Widget _buildAttrField(FieldDescriptor field, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final Color brandPrimary = cs.primary;

    if (field.type == 'enum') {
      final options = field.enumOptions ?? const [];
      final currentValue = _editingEnumValues[field.key] ?? (options.isNotEmpty ? options.first : '');

      return _buildDropdownField(
        field: field,
        focusNode: _focusNodes[field.key]!,
        value: currentValue,
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
        onChanged: widget.readOnly
            ? null
            : (String? val) {
          if (val != null) {
            setState(() {
              _editingEnumValues[field.key] = val;
            });
            _notifyDirtyIfChanged();
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
        field: field,
        controller: _controllers[field.key]!,
        focusNode: _focusNodes[field.key]!,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        errorText: _errors[field.key],
        brandPrimary: brandPrimary,
      );
    }
  }

  /// Builds the label row for [field], showing a small circular dirty indicator
  /// dot beside the field name when the field's current value differs from its
  /// last committed state.
  ///
  /// The indicator uses the theme's primary color so it is visible in both
  /// light and dark modes. Always returns a [Row] so the widget subtree
  /// structure is stable across dirty-state transitions.
  Widget _buildFieldLabel(FieldDescriptor field) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFieldDirty(field))
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        Text(field.label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  /// Builds a labelled [TextField] bound to [controller] and [focusNode].
  ///
  /// The text field uses [widget.inputBorderRadius] for its [OutlineInputBorder]
  /// and displays [errorText] below the field when validation fails. The
  /// border color switches to the theme error color when an error is present
  /// and to [brandPrimary] when focused.
  ///
  /// The label is rendered above the field using the theme's `labelSmall` text
  /// style, with an optional dirty indicator dot via [_buildFieldLabel].
  /// Keyboard type and input formatters are forwarded to the
  /// [TextField] unchanged; pass null for [inputFormatters] when no
  /// formatting is required.
  Widget _buildTextField({
    required FieldDescriptor field,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    required Color brandPrimary,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (field.refType != null && widget.onViewSelected != null) {
      final value = controller.text;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(field),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => widget.onViewSelected!(field.refType!, value),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: widget.gapSize),
        TextField(
          enabled: !widget.readOnly,
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
              borderRadius: widget.inputBorderRadius,
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: widget.inputBorderRadius,
              borderSide: BorderSide(
                color: errorText != null ? Theme.of(context).colorScheme.error : brandPrimary,
                width: 1.5,
              ),
            ),
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

  /// Builds a labelled [DropdownButtonFormField] bound to [focusNode].
  ///
  /// The dropdown uses [widget.inputBorderRadius] for its [OutlineInputBorder]
  /// and displays [errorText] below the field when validation fails. Its
  /// background adjusts to the current brightness via [isDark] to remain
  /// legible in both light and dark themes.
  ///
  /// The label is rendered above the dropdown using the theme's `labelSmall`
  /// text style, with an optional dirty indicator dot via [_buildFieldLabel].
  /// The [onChanged] callback updates [_editingEnumValues] and then calls
  /// [_triggerBlurSave] so that enum value changes are validated and
  /// committed immediately.
  Widget _buildDropdownField({
    required FieldDescriptor field,
    required FocusNode focusNode,
    required String value,
    required List<DropdownMenuItem<String>> items,
    ValueChanged<String?>? onChanged,
    String? errorText,
    required bool isDark,
    required Color brandPrimary,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (field.refType != null && widget.onViewSelected != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(field),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => widget.onViewSelected!(field.refType!, value),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: widget.gapSize),
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
                borderRadius: widget.inputBorderRadius,
                borderSide: BorderSide(
                  color: errorText != null
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: widget.inputBorderRadius,
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

  /// Builds a read-only panel showing the current [committedData] as
  /// pretty-printed JSON.
  ///
  /// Exists primarily for development and debugging workflows where operators
  /// need to inspect the accumulated committed values at a glance. The panel
  /// scrolls horizontally to accommodate wide payloads without wrapping.
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
            'Saved State',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(height: widget.gapSize),
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
