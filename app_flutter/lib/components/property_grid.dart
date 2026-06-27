import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/domain/types.dart';
import 'package:app_flutter/domain/validation.dart';
import 'package:app_flutter/domain/schema.dart';

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
  final Function? onSave;
  final String activeView;

  const PropertyGrid({
    super.key,
    this.attributes,
    this.initialValues = const {},
    this.onSave,
    this.activeView = 'Location',
  });

  @override
  State<PropertyGrid> createState() => _PropertyGridState();
}

class _PropertyGridState extends State<PropertyGrid> {
  // Design Token Colors
  static const Color brandPrimary = Color(0xFF1A73E8);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color borderLight = Color(0xFFDADCE0);
  static const Color borderDark = Color(0xFF3C4043);
  static const Color surfaceLight = Color(0xFFF1F3F4);
  static const Color surfaceDark = Color(0xFF202124);
  static const Color terminalBgDark = Color(0xFF18191C);
  static const Color terminalBgLight = Color(0xFFE8EAED);

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
    committedData = Map<String, dynamic>.from(widget.initialValues.isEmpty ? {
      'latitude': 37.7749,
      'longitude': -122.4194,
      'altitude': 10,
      'roomName': 'Main-Data-Room',
      'gridRow': 12,
      'gridColumn': 4,
      'maxVoltage': 240.0,
      'maxAllocatedPower': 15000.0,
      'countryCode': 'US',
      'locationType': 'room',
    } : widget.initialValues);
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

      if (attr.type != 'enum') {
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
        committedData = Map<String, dynamic>.from(widget.initialValues.isEmpty ? {
          'latitude': 37.7749,
          'longitude': -122.4194,
          'altitude': 10,
          'roomName': 'Main-Data-Room',
          'gridRow': 12,
          'gridColumn': 4,
          'maxVoltage': 240.0,
          'maxAllocatedPower': 15000.0,
          'countryCode': 'US',
          'locationType': 'room',
        } : widget.initialValues);
        _initializeFields(_resolvedAttributes, committedData);
      });
    } else {
      setState(() {
        if (widget.initialValues.isNotEmpty) {
          committedData = Map<String, dynamic>.from(widget.initialValues);
        }
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

  void _triggerBlurSave(String key, AttributeDefinition attr) {
    final valueString = attr.type == 'enum'
        ? (committedData[key]?.toString() ?? '')
        : (_controllers[key]?.text ?? '');
    final Map<String, String> newErrors = Map<String, String>.from(_errors);

    dynamic parsedValue;
    bool isValid = true;
    String? error;

    // 1. Is Required check
    if (attr.isRequired && valueString.trim().isEmpty) {
      isValid = false;
      error = '${attr.label} is required';
    }

    // 2. Parse numeric values if double or int
    if (isValid) {
      if (attr.type == 'double') {
        final val = double.tryParse(valueString);
        if (val == null && valueString.isNotEmpty) {
          isValid = false;
          error = 'Must be a valid double';
        } else {
          parsedValue = val;
        }
      } else if (attr.type == 'int') {
        final val = int.tryParse(valueString);
        if (val == null && valueString.isNotEmpty) {
          isValid = false;
          error = 'Must be a valid integer';
        } else {
          parsedValue = val;
        }
      } else {
        parsedValue = valueString;
      }
    }

    // 3. Regex checks
    if (isValid && attr.regexPattern != null && valueString.isNotEmpty) {
      final reg = RegExp(attr.regexPattern!);
      if (!reg.hasMatch(valueString)) {
        isValid = false;
        error = 'Invalid format';
      }
    }

    // 4. Min/Max value checks
    if (isValid && parsedValue is num) {
      if (attr.minValue != null && parsedValue < attr.minValue!) {
        isValid = false;
        error = 'Value cannot be less than ${attr.minValue}';
      }
      if (attr.maxValue != null && parsedValue > attr.maxValue!) {
        isValid = false;
        error = 'Value cannot be greater than ${attr.maxValue}';
      }
    }

    // 5. Special fallback checks for backwards compatibility with tests / original validations
    if (isValid) {
      if (key == 'countryCode') {
        final code = valueString;
        final isCountryValid = validatePhysicalAddress(
          PhysicalAddress(
            address: '',
            postalCode: '',
            state: '',
            city: '',
            countryCode: code,
          ),
        );
        if (!isCountryValid) {
          isValid = false;
          error = 'Must match ISO 2-letter uppercase pattern (e.g. US, FI)';
        }
      } else if (key == 'locationType') {
        final typeStr = valueString;
        final isLocTypeValid = validateLocationType(
          LocationType(
            identity: typeStr,
          ),
        );
        if (!isLocTypeValid) {
          isValid = false;
          error = "Must be 'site', 'room', or 'building'";
        }
      } else if (key == 'maxVoltage' || key == 'maxAllocatedPower') {
        final vText = _controllers['maxVoltage']?.text ?? '0';
        final pText = _controllers['maxAllocatedPower']?.text ?? '0';
        final rName = _controllers['roomName']?.text ?? '';
        final gRow = int.tryParse(_controllers['gridRow']?.text ?? '0') ?? 0;
        final gCol = int.tryParse(_controllers['gridColumn']?.text ?? '0') ?? 0;

        final double voltageVal = double.tryParse(vText) ?? 0.0;
        final double powerVal = double.tryParse(pText) ?? 0.0;

        final bool isRackValid = validateRack(
          Rack(
            maxVoltage: voltageVal,
            maxAllocatedPower: powerVal,
            heightUnits: 42,
            location: RackLocation(
              roomName: rName,
              gridRow: gRow,
              gridColumn: gCol,
            ),
          ),
        );

        if (!isRackValid) {
          isValid = false;
          error = 'Value cannot be negative';
        }
      }
    }

    setState(() {
      if (isValid) {
        newErrors.remove(key);
        if (key == 'maxVoltage' || key == 'maxAllocatedPower') {
          final double voltageVal = double.tryParse(_controllers['maxVoltage']?.text ?? '0') ?? 0.0;
          final double powerVal = double.tryParse(_controllers['maxAllocatedPower']?.text ?? '0') ?? 0.0;
          if (voltageVal >= 0 && powerVal >= 0) {
            newErrors.remove('maxVoltage');
            newErrors.remove('maxAllocatedPower');
          }
        }
      } else {
        newErrors[key] = error ?? 'Invalid value';
      }
      _errors = newErrors;
    });

    if (isValid) {
      dynamic finalCastedValue = parsedValue;
      if (attr.type == 'double') {
        finalCastedValue = double.tryParse(valueString) ?? 0.0;
      } else if (attr.type == 'int') {
        finalCastedValue = int.tryParse(valueString) ?? 0;
      }
      setState(() {
        committedData[key] = finalCastedValue;
      });

      if (widget.onSave != null) {
        final saveFunc = widget.onSave!;
        try {
          (saveFunc as dynamic)(key, finalCastedValue);
        } catch (_) {
          try {
            (saveFunc as dynamic)(committedData);
          } catch (_) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final groups = <String>{};
    for (final attr in _resolvedAttributes) {
      groups.add(attr.sectionGroup);
    }
    
    // Sort so 'Location' is always first, then 'Alternate', then any other groups
    final List<String> sortedGroups = groups.toList();
    sortedGroups.sort((a, b) {
      if (a == 'Location') return -1;
      if (b == 'Location') return 1;
      if (a == 'Alternate') return -1;
      if (b == 'Alternate') return 1;
      return a.compareTo(b);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16.0) / 2.0
                  : constraints.maxWidth;

              final List<Widget> sections = sortedGroups.map((group) {
                final bool isActive = (group == 'Location' && (widget.activeView == 'Location' || widget.activeView == 'Ingestion')) ||
                                     (group == 'Alternate' && widget.activeView != 'Location' && widget.activeView != 'Ingestion') ||
                                     (group != 'Location' && group != 'Alternate' && widget.activeView == group);

                String title = '$group Section';
                if (group == 'Location') {
                  title = 'Geodetic Coordinate Frame';
                } else if (group == 'Alternate') {
                  title = 'Alternate Structural Grid Frame';
                }

                return _buildSystemSection(
                  title: title,
                  isActive: isActive,
                  isAlternate: group == 'Alternate',
                  isDark: isDark,
                  width: cardWidth,
                  child: _buildGroupFields(group, isDark),
                );
              }).toList();

              if (constraints.maxWidth > 700 && sections.length >= 2) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sections[0],
                    const SizedBox(width: 16.0),
                    sections[1],
                  ],
                );
              } else {
                final List<Widget> columnChildren = [];
                for (int i = 0; i < sections.length; i++) {
                  columnChildren.add(sections[i]);
                  if (i < sections.length - 1) {
                    columnChildren.add(const SizedBox(height: 16.0));
                  }
                }
                return Column(children: columnChildren);
              }
            },
          ),
          const SizedBox(height: 20.0),
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
    final Color borderActive = brandPrimary;
    final Color borderDimmed = isDark ? borderDark : borderLight;

    return Opacity(
      opacity: isActive ? 1.0 : 0.65,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? surfaceDark : surfaceLight,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isActive ? borderActive : borderDimmed,
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: brandPrimary.withValues(alpha: 0.1),
                    blurRadius: 24.0,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF202124),
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isAlternate
                          ? const Color(0x2600D2FF)
                          : const Color(0x261A73E8),
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: isAlternate
                            ? const Color(0x4D00D2FF)
                            : const Color(0x4D1A73E8),
                      ),
                    ),
                    child: Text(
                      'Active Reference',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: isAlternate
                            ? const Color(0xFF00D2FF)
                            : brandPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18.0),
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
        final bool shouldPair = (attr.key == 'gridRow' && nextAttr.key == 'gridColumn') ||
                                (attr.key == 'maxVoltage' && nextAttr.key == 'maxAllocatedPower') ||
                                (attr.key == 'countryCode' && nextAttr.key == 'locationType');
        if (shouldPair) {
          fields.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAttrField(attr, isDark)),
                const SizedBox(width: 12.0),
                Expanded(child: _buildAttrField(nextAttr, isDark)),
              ],
            ),
          );
          fields.add(const SizedBox(height: 14.0));
          i += 2;
          continue;
        }
      }

      fields.add(_buildAttrField(attr, isDark));
      fields.add(const SizedBox(height: 14.0));
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
    if (attr.type == 'enum') {
      final options = attr.options ?? const [];
      final currentValue = committedData[attr.key] ?? (options.isNotEmpty ? options.first : '');

      return _buildDropdownField(
        label: attr.label,
        key: attr.key,
        focusNode: _focusNodes[attr.key]!,
        value: currentValue as String,
        errorText: _errors[attr.key],
        isDark: isDark,
        items: options.map((opt) {
          String displayName = opt;
          if (opt == 'site') displayName = 'Site';
          else if (opt == 'room') displayName = 'Room';
          else if (opt == 'building') displayName = 'Building';
          else if (opt == 'invalid-test-option') displayName = 'Invalid (Test Only)';

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

      if (attr.type == 'double') {
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
      } else if (attr.type == 'int') {
        keyboardType = TextInputType.number;
      }

      if (attr.key == 'countryCode') {
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
        isDark: isDark,
        onChanged: (String val) {
          // Keep buffered state updated
        },
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
    required bool isDark,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6.0),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            fontSize: 13.0,
            color: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF202124),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            filled: true,
            fillColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.redAccent
                    : (isDark ? borderDark : borderLight),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : brandPrimary,
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
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String key,
    required FocusNode focusNode,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? errorText,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6.0),
        Focus(
          focusNode: focusNode,
          onFocusChange: (bool hasFocus) {
            if (!hasFocus) {
              final index = _resolvedAttributes.indexWhere((a) => a.key == key);
              if (index != -1) {
                _triggerBlurSave(key, _resolvedAttributes[index]);
              }
            }
          },
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: value,
            dropdownColor: isDark ? surfaceDark : Colors.white,
            style: TextStyle(
              fontSize: 13.0,
              color: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF202124),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              filled: true,
              fillColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Colors.redAccent
                      : (isDark ? borderDark : borderLight),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: errorText != null ? Colors.redAccent : brandPrimary,
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
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommittedStatePanel(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? terminalBgDark : terminalBgLight,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isDark ? borderDark : borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Committed Pipeline Scope Data (onBlur verified)',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFEEEEEE) : const Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: isDark ? borderDark : borderLight,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                const JsonEncoder.withIndent('  ').convert(committedData),
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                  color: Color(0xFF34A853),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
