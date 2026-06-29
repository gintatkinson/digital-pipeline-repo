import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/features/properties/property_defaults.dart';

/// UpperCaseTextFormatter forces character inputs to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// PropertyGrid renders a key-value attribute grid mapped to a schema.
class PropertyGrid extends StatefulWidget {
  final List<AttributeDefinition>? attributes;
  final Map<String, dynamic> initialValues;
  final void Function(Map<String, dynamic>)? onSave;
  final String activeView;
  final Map<String, dynamic> fallbackInitialValues;
  final String? Function(String key, String value, Map<String, dynamic> allValues)? validator;
  final Map<String, Map<String, String>>? optionDisplayNames;
  final bool Function(AttributeDefinition first, AttributeDefinition second)? shouldPair;

  const PropertyGrid({
    super.key,
    this.attributes,
    this.initialValues = const {},
    this.onSave,
    this.activeView = 'Location',
    this.fallbackInitialValues = defaultFallbackInitialValues,
    this.validator = defaultValidator,
    this.optionDisplayNames = defaultOptionDisplayNames,
    this.shouldPair = defaultShouldPair,
  });

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

const _sectionLocation = 'Location';
const _sectionAlternate = 'Alternate';
const _viewIngestion = 'Ingestion';
const _typeDouble = 'double';
const _typeInt = 'int';
const _typeEnum = 'enum';
const _keyMaxVoltage = 'maxVoltage';
const _keyMaxAllocatedPower = 'maxAllocatedPower';
const _keyCountryCode = 'countryCode';
const _wideLayoutBreakpoint = 700.0;
const _inactiveSectionOpacity = 0.65;
const _activeShadowOpacity = 0.1;
const _inactiveShadowOpacity = 0.05;
const _activeBadgeBgOpacity = 0.15;
const _activeBadgeBorderOpacity = 0.3;

class _PropertyGridState extends State<PropertyGrid> {
  late List<AttributeDefinition> _resolvedAttributes;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  Map<String, String> _errors = const {};
  final Map<String, bool> _hadFocus = {};

  /// Local committed state simulated for this component scope.
  late Map<String, dynamic> committedData;

  @override
  void initState() {
    super.initState();
    _resolvedAttributes = widget.attributes ?? defaultCoordinateAttributes;
    committedData = Map<String, dynamic>.from(widget.initialValues.isEmpty ? widget.fallbackInitialValues : widget.initialValues);
    _initializeFields(_resolvedAttributes, committedData);
  }

  void _initializeFields(List<AttributeDefinition> attributes, Map<String, dynamic> nodeData) {
    for (final attr in attributes) {
      final val = nodeData[attr.key];
      final text = val != null ? val.toString() : '';
      final controller = TextEditingController(text: text);
      final focusNode = FocusNode();

      _controllers[attr.key] = controller;
      _focusNodes[attr.key] = focusNode;
      _hadFocus[attr.key] = false;

      if (attr.type != _typeEnum) {
        focusNode.addListener(() {
          final bool currentlyHasFocus = focusNode.hasFocus;
          final bool previouslyHadFocus = _hadFocus[attr.key] ?? false;
          _hadFocus[attr.key] = currentlyHasFocus;

          if (previouslyHadFocus && !currentlyHasFocus) {
            _triggerBlurSave(attr.key, attr);
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

    final oldAttrs = oldWidget.attributes ?? defaultCoordinateAttributes;
    final newAttrs = widget.attributes ?? defaultCoordinateAttributes;

    bool attributesChanged = oldAttrs.length != newAttrs.length;
    if (!attributesChanged) {
      for (int i = 0; i < newAttrs.length; i++) {
        if (oldAttrs[i].key != newAttrs[i].key ||
            oldAttrs[i].type != newAttrs[i].type ||
            oldAttrs[i].sectionGroup != newAttrs[i].sectionGroup) {
          attributesChanged = true;
          break;
        }
      }
    }

    if (attributesChanged) {
      setState(() {
        _disposeAllFields();
        _resolvedAttributes = newAttrs;
        committedData = Map<String, dynamic>.from(widget.initialValues.isEmpty ? widget.fallbackInitialValues : widget.initialValues);
        _initializeFields(_resolvedAttributes, committedData);
      });
    } else {
      setState(() {
        if (widget.initialValues.isNotEmpty) {
          committedData = Map<String, dynamic>.from(widget.initialValues);
        }
        _errors = const {};
        for (final attr in _resolvedAttributes) {
          final focusNode = _focusNodes[attr.key];
          if (focusNode != null && !focusNode.hasFocus) {
            final newVal = widget.initialValues[attr.key] ?? committedData[attr.key];
            final text = newVal != null ? newVal.toString() : '';
            _controllers[attr.key]?.text = text;
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

  Map<String, dynamic> _buildAllValuesMap() {
    final Map<String, dynamic> allValues = {};
    for (final resolvedAttr in _resolvedAttributes) {
      final ctrl = _controllers[resolvedAttr.key];
      if (resolvedAttr.type == _typeEnum) {
        allValues[resolvedAttr.key] = committedData[resolvedAttr.key]?.toString() ?? '';
      } else {
        allValues[resolvedAttr.key] = ctrl?.text ?? committedData[resolvedAttr.key];
      }
    }
    return allValues;
  }

  void _clearPairedErrors(String key, Map<String, String> newErrors) {
    if (key != _keyMaxVoltage && key != _keyMaxAllocatedPower) return;
    final otherKey = key == _keyMaxVoltage ? _keyMaxAllocatedPower : _keyMaxVoltage;
    final otherCtrl = _controllers[otherKey];
    if (otherCtrl == null) return;
    final allValues = _buildAllValuesMap();
    final otherErrorMsg = widget.validator?.call(otherKey, otherCtrl.text, allValues);
    if (otherErrorMsg == null) {
      newErrors.remove(otherKey);
    }
  }

  (bool isValid, dynamic parsedValue, String? error) _validateField(
    String key, AttributeDefinition attr, String valueString,
  ) {
    dynamic parsedValue;

    if (attr.isRequired && valueString.trim().isEmpty) {
      return (false, null, '${attr.label} is required');
    }

    if (attr.type == _typeDouble) {
      final val = double.tryParse(valueString);
      if (val == null && valueString.isNotEmpty) {
        return (false, null, 'Must be a valid double');
      }
      parsedValue = val;
    } else if (attr.type == _typeInt) {
      final val = int.tryParse(valueString);
      if (val == null && valueString.isNotEmpty) {
        return (false, null, 'Must be a valid integer');
      }
      parsedValue = val;
    } else {
      parsedValue = valueString;
    }

    if (attr.regexPattern != null && valueString.isNotEmpty) {
      final reg = RegExp(attr.regexPattern!);
      if (!reg.hasMatch(valueString)) {
        return (false, parsedValue, 'Invalid format');
      }
    }

    if (parsedValue is num) {
      if (attr.minValue != null && parsedValue < attr.minValue!) {
        return (false, parsedValue, 'Value cannot be less than ${attr.minValue}');
      }
      if (attr.maxValue != null && parsedValue > attr.maxValue!) {
        return (false, parsedValue, 'Value cannot be greater than ${attr.maxValue}');
      }
    }

    if (widget.validator != null) {
      final allValues = _buildAllValuesMap();
      final errorMsg = widget.validator!(key, valueString, allValues);
      if (errorMsg != null) {
        return (false, parsedValue, errorMsg);
      }
    }

    return (true, parsedValue, null);
  }

  void _triggerBlurSave(String key, AttributeDefinition attr) {
    final valueString = attr.type == _typeEnum
        ? (committedData[key]?.toString() ?? '')
        : (_controllers[key]?.text ?? '');
    final Map<String, String> newErrors = Map<String, String>.from(_errors);

    final (bool isValid, dynamic parsedValue, String? error) = _validateField(key, attr, valueString);

    setState(() {
      if (isValid) {
        newErrors.remove(key);
        _clearPairedErrors(key, newErrors);
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final groups = <String>{};
    for (final attr in _resolvedAttributes) {
      groups.add(attr.sectionGroup);
    }
    
    final List<String> sortedGroups = groups.toList();
    sortedGroups.sort((a, b) {
      if (a == _sectionLocation) return -1;
      if (b == _sectionLocation) return 1;
      if (a == _sectionAlternate) return -1;
      if (b == _sectionAlternate) return 1;
      return a.compareTo(b);
    });

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
                final bool isActive = (group == _sectionLocation && (widget.activeView == _sectionLocation || widget.activeView == _viewIngestion)) ||
                                     (group == _sectionAlternate && widget.activeView != _sectionLocation && widget.activeView != _viewIngestion) ||
                                     (group != _sectionLocation && group != _sectionAlternate && widget.activeView == group);

                String title = '$group Section';
                if (group == _sectionLocation) {
                  title = 'Geodetic Coordinate Frame';
                } else if (group == _sectionAlternate) {
                  title = 'Alternate Structural Grid Frame';
                }

                return _buildSystemSection(
                  title: title,
                  isActive: isActive,
                  isAlternate: group == _sectionAlternate,
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
    required bool isAlternate,
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
    final groupAttrs = _resolvedAttributes.where((attr) => attr.sectionGroup == group).toList();

    final List<Widget> fields = [];
    int i = 0;
    while (i < groupAttrs.length) {
      final attr = groupAttrs[i];

      if (i + 1 < groupAttrs.length) {
        final nextAttr = groupAttrs[i + 1];
        final bool shouldPair = widget.shouldPair?.call(attr, nextAttr) ?? false;
        if (shouldPair) {
          fields.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAttrField(attr, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildAttrField(nextAttr, isDark)),
              ],
            ),
          );
          fields.add(const SizedBox(height: 8));
          i += 2;
          continue;
        }
      }

      fields.add(_buildAttrField(attr, isDark));
      fields.add(const SizedBox(height: 8));
      i++;
    }

    if (fields.isNotEmpty) {
      fields.removeLast();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  Widget _buildAttrField(AttributeDefinition attr, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final Color brandPrimary = cs.primary;


    if (attr.type == _typeEnum) {
      final options = attr.options ?? const [];
      final currentValue = committedData[attr.key] ?? (options.isNotEmpty ? options.first : '');

      return _buildDropdownField(
        label: attr.label,
        focusNode: _focusNodes[attr.key]!,
        value: currentValue as String,
        errorText: _errors[attr.key],
        isDark: isDark,
        brandPrimary: brandPrimary,
        items: options.map((opt) {
          String displayName = opt;
          final optionMap = widget.optionDisplayNames?[attr.key];
          if (optionMap != null && optionMap.containsKey(opt)) {
            displayName = optionMap[opt]!;
          }

          return DropdownMenuItem<String>(
            value: opt,
            child: Text(displayName),
          );
        }).toList(),
        onChanged: (String? val) {
          if (val != null) {
            setState(() {
              committedData[attr.key] = val;
            });
            _triggerBlurSave(attr.key, attr);
          }
        },
      );
    } else {
      TextInputType keyboardType = TextInputType.text;
      List<TextInputFormatter>? inputFormatters;

      if (attr.type == _typeDouble) {
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
      } else if (attr.type == _typeInt) {
        keyboardType = TextInputType.number;
      }

      if (attr.key == _keyCountryCode) {
        inputFormatters = [
          LengthLimitingTextInputFormatter(2),
          UpperCaseTextFormatter(),
        ];
      }

      return _buildTextField(
        label: attr.label,
        controller: _controllers[attr.key]!,
        focusNode: _focusNodes[attr.key]!,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        errorText: _errors[attr.key],
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
            // ignore: deprecated_member_use
            value: value,
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
            'Committed Pipeline Scope Data (onBlur verified)',
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
