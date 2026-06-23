import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_flutter/domain/types.dart';
import 'package:app_flutter/domain/validation.dart';

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
///
/// It buffers input values locally, performs validation on loss of focus,
/// and commits to the parent state (committedData) and triggers [onSave]
/// only if validation passes.
///
/// Realizes UML::PropertyGrid.
class PropertyGrid extends StatefulWidget {
  /// The active view category (e.g. 'Location', 'Ingestion', etc.).
  final String activeView;

  /// Callback triggered when changes are successfully validated and saved.
  final ValueChanged<Map<String, dynamic>>? onSave;

  const PropertyGrid({
    super.key,
    required this.activeView,
    this.onSave,
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

  /// Parent/committed state simulated for this component scope.
  late Map<String, dynamic> committedData;

  /// Local buffered data to prevent parent re-renders on keystroke.
  late Map<String, dynamic> bufferedData;

  /// Validation errors map.
  Map<String, String> errors = const <String, String>{};

  /// Tracks focus states to only run validation on transition from focused to unfocused (blur).
  final Map<String, bool> _hadFocus = <String, bool>{};

  // Text Controllers for local buffering
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;
  late final TextEditingController altitudeController;
  late final TextEditingController roomNameController;
  late final TextEditingController gridRowController;
  late final TextEditingController gridColumnController;
  late final TextEditingController maxVoltageController;
  late final TextEditingController maxAllocatedPowerController;
  late final TextEditingController countryCodeController;

  // Focus nodes to capture loss of focus (blur) events
  late final FocusNode latitudeFocusNode;
  late final FocusNode longitudeFocusNode;
  late final FocusNode altitudeFocusNode;
  late final FocusNode roomNameFocusNode;
  late final FocusNode gridRowFocusNode;
  late final FocusNode gridColumnFocusNode;
  late final FocusNode maxVoltageFocusNode;
  late final FocusNode maxAllocatedPowerFocusNode;
  late final FocusNode countryCodeFocusNode;
  late final FocusNode locationTypeFocusNode;

  @override
  void initState() {
    super.initState();
    // Default initial committed state
    committedData = <String, dynamic>{
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
    };
    bufferedData = Map<String, dynamic>.from(committedData);

    // Initialize text controllers
    latitudeController = TextEditingController(text: bufferedData['latitude'].toString());
    longitudeController = TextEditingController(text: bufferedData['longitude'].toString());
    altitudeController = TextEditingController(text: bufferedData['altitude'].toString());
    roomNameController = TextEditingController(text: bufferedData['roomName'].toString());
    gridRowController = TextEditingController(text: bufferedData['gridRow'].toString());
    gridColumnController = TextEditingController(text: bufferedData['gridColumn'].toString());
    maxVoltageController = TextEditingController(text: bufferedData['maxVoltage'].toString());
    maxAllocatedPowerController = TextEditingController(text: bufferedData['maxAllocatedPower'].toString());
    countryCodeController = TextEditingController(text: bufferedData['countryCode'].toString());

    // Initialize focus nodes
    latitudeFocusNode = FocusNode();
    longitudeFocusNode = FocusNode();
    altitudeFocusNode = FocusNode();
    roomNameFocusNode = FocusNode();
    gridRowFocusNode = FocusNode();
    gridColumnFocusNode = FocusNode();
    maxVoltageFocusNode = FocusNode();
    maxAllocatedPowerFocusNode = FocusNode();
    countryCodeFocusNode = FocusNode();
    locationTypeFocusNode = FocusNode();

    // Listeners for focus loss (blur) to trigger validation & commit
    latitudeFocusNode.addListener(() => _onBlur('latitude', latitudeController.text));
    longitudeFocusNode.addListener(() => _onBlur('longitude', longitudeController.text));
    altitudeFocusNode.addListener(() => _onBlur('altitude', altitudeController.text));
    roomNameFocusNode.addListener(() => _onBlur('roomName', roomNameController.text));
    gridRowFocusNode.addListener(() => _onBlur('gridRow', gridRowController.text));
    gridColumnFocusNode.addListener(() => _onBlur('gridColumn', gridColumnController.text));
    maxVoltageFocusNode.addListener(() => _onBlur('maxVoltage', maxVoltageController.text));
    maxAllocatedPowerFocusNode.addListener(() => _onBlur('maxAllocatedPower', maxAllocatedPowerController.text));
    countryCodeFocusNode.addListener(() => _onBlur('countryCode', countryCodeController.text));
  }

  @override
  void didUpdateWidget(PropertyGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Synchronize buffer when activeView changes or parent state updates
    if (widget.activeView != oldWidget.activeView) {
      setState(() {
        _syncControllersWithCommitted();
        errors = const <String, String>{};
      });
    }
  }

  @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    altitudeController.dispose();
    roomNameController.dispose();
    gridRowController.dispose();
    gridColumnController.dispose();
    maxVoltageController.dispose();
    maxAllocatedPowerController.dispose();
    countryCodeController.dispose();

    latitudeFocusNode.dispose();
    longitudeFocusNode.dispose();
    altitudeFocusNode.dispose();
    roomNameFocusNode.dispose();
    gridRowFocusNode.dispose();
    gridColumnFocusNode.dispose();
    maxVoltageFocusNode.dispose();
    maxAllocatedPowerFocusNode.dispose();
    countryCodeFocusNode.dispose();
    locationTypeFocusNode.dispose();
    super.dispose();
  }

  /// Syncs all controller values and buffer with the committed data.
  void _syncControllersWithCommitted() {
    bufferedData = Map<String, dynamic>.from(committedData);
    latitudeController.text = bufferedData['latitude'].toString();
    longitudeController.text = bufferedData['longitude'].toString();
    altitudeController.text = bufferedData['altitude'].toString();
    roomNameController.text = bufferedData['roomName'].toString();
    gridRowController.text = bufferedData['gridRow'].toString();
    gridColumnController.text = bufferedData['gridColumn'].toString();
    maxVoltageController.text = bufferedData['maxVoltage'].toString();
    maxAllocatedPowerController.text = bufferedData['maxAllocatedPower'].toString();
    countryCodeController.text = bufferedData['countryCode'].toString();
  }

  /// Handle validation and state commit on blur.
  void _onBlur(String field, String textValue) {
    FocusNode? focusNode;
    switch (field) {
      case 'latitude': focusNode = latitudeFocusNode; break;
      case 'longitude': focusNode = longitudeFocusNode; break;
      case 'altitude': focusNode = altitudeFocusNode; break;
      case 'roomName': focusNode = roomNameFocusNode; break;
      case 'gridRow': focusNode = gridRowFocusNode; break;
      case 'gridColumn': focusNode = gridColumnFocusNode; break;
      case 'maxVoltage': focusNode = maxVoltageFocusNode; break;
      case 'maxAllocatedPower': focusNode = maxAllocatedPowerFocusNode; break;
      case 'countryCode': focusNode = countryCodeFocusNode; break;
    }

    if (focusNode != null) {
      final bool currentlyHasFocus = focusNode.hasFocus;
      final bool previouslyHadFocus = _hadFocus[field] ?? false;
      _hadFocus[field] = currentlyHasFocus;

      // Blur is identified by a transition from true (had focus) to false (lost focus)
      if (previouslyHadFocus && !currentlyHasFocus) {
        _validateAndSaveField(field, textValue);
      }
    }
  }

  /// Performs specific domain validation and commits changes if validation passes.
  void _validateAndSaveField(String field, dynamic val) {
    final Map<String, String> newErrors = Map<String, String>.from(errors);
    bool isValid = true;

    if (field == 'countryCode') {
      final String code = val.toString();
      final bool isCountryValid = validatePhysicalAddress(
        PhysicalAddress(
          address: '',
          postalCode: '',
          state: '',
          city: '',
          countryCode: code,
        ),
      );
      if (!isCountryValid) {
        newErrors['countryCode'] = 'Must match ISO 2-letter uppercase pattern (e.g. US, FI)';
        isValid = false;
      } else {
        newErrors.remove('countryCode');
      }
    }

    if (field == 'locationType') {
      final String typeStr = val.toString();
      final bool isLocTypeValid = validateLocationType(
        LocationType(
          identity: typeStr,
        ),
      );
      if (!isLocTypeValid) {
        newErrors['locationType'] = "Must be 'site', 'room', or 'building'";
        isValid = false;
      } else {
        newErrors.remove('locationType');
      }
    }

    if (field == 'maxVoltage' || field == 'maxAllocatedPower') {
      final double voltageVal = field == 'maxVoltage'
          ? (double.tryParse(val.toString()) ?? 0.0)
          : (double.tryParse(maxVoltageController.text) ?? 0.0);
      final double powerVal = field == 'maxAllocatedPower'
          ? (double.tryParse(val.toString()) ?? 0.0)
          : (double.tryParse(maxAllocatedPowerController.text) ?? 0.0);

      final bool isRackValid = validateRack(
        Rack(
          maxVoltage: voltageVal,
          maxAllocatedPower: powerVal,
          heightUnits: 42,
          location: RackLocation(
            roomName: roomNameController.text,
            gridRow: int.tryParse(gridRowController.text) ?? 0,
            gridColumn: int.tryParse(gridColumnController.text) ?? 0,
          ),
        ),
      );

      if (!isRackValid) {
        newErrors[field] = 'Value cannot be negative';
        isValid = false;
      } else {
        newErrors.remove(field);
      }
    }

    setState(() {
      errors = newErrors;
    });

    if (isValid) {
      setState(() {
        if (field == 'latitude' || field == 'longitude' || field == 'maxVoltage' || field == 'maxAllocatedPower') {
          committedData[field] = double.tryParse(val.toString()) ?? 0.0;
        } else if (field == 'altitude' || field == 'gridRow' || field == 'gridColumn') {
          committedData[field] = int.tryParse(val.toString()) ?? 0;
        } else {
          committedData[field] = val;
        }
      });
      if (widget.onSave != null) {
        widget.onSave!(committedData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isGeodeticActive = widget.activeView == 'Location' || widget.activeView == 'Ingestion';
    final bool isAlternateActive = !isGeodeticActive;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System sections layout
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cardWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 16.0) / 2.0
                  : constraints.maxWidth;

              final List<Widget> sections = [
                _buildSystemSection(
                  title: 'Geodetic Coordinate Frame',
                  isActive: isGeodeticActive,
                  isAlternate: false,
                  isDark: isDark,
                  width: cardWidth,
                  child: _buildGeodeticFormFields(isDark),
                ),
                _buildSystemSection(
                  title: 'Alternate Structural Grid Frame',
                  isActive: isAlternateActive,
                  isAlternate: true,
                  isDark: isDark,
                  width: cardWidth,
                  child: _buildAlternateFormFields(isDark),
                ),
              ];

              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sections[0],
                    const SizedBox(width: 16.0),
                    sections[1],
                  ],
                );
              } else {
                return Column(
                  children: [
                    sections[0],
                    const SizedBox(height: 16.0),
                    sections[1],
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20.0),
          // Committed state display panel
          _buildCommittedStatePanel(isDark),
        ],
      ),
    );
  }

  /// Builds a dynamic system section card container.
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
            // Section Header
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
                          ? const Color(0x2600D2FF) // light cyan/teal background
                          : const Color(0x261A73E8), // light blue background
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

  /// Builds the Geodetic Frame form fields.
  Widget _buildGeodeticFormFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Latitude',
          controller: latitudeController,
          focusNode: latitudeFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isDark: isDark,
          onChanged: (String val) {
            bufferedData['latitude'] = double.tryParse(val) ?? 0.0;
          },
        ),
        const SizedBox(height: 14.0),
        _buildTextField(
          label: 'Longitude',
          controller: longitudeController,
          focusNode: longitudeFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isDark: isDark,
          onChanged: (String val) {
            bufferedData['longitude'] = double.tryParse(val) ?? 0.0;
          },
        ),
        const SizedBox(height: 14.0),
        _buildTextField(
          label: 'Elevation / Altitude (m)',
          controller: altitudeController,
          focusNode: altitudeFocusNode,
          keyboardType: TextInputType.number,
          isDark: isDark,
          onChanged: (String val) {
            bufferedData['altitude'] = int.tryParse(val) ?? 0;
          },
        ),
      ],
    );
  }

  /// Builds the Alternate Structural Grid Frame form fields.
  Widget _buildAlternateFormFields(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Room Identifier',
          controller: roomNameController,
          focusNode: roomNameFocusNode,
          isDark: isDark,
          onChanged: (String val) {
            bufferedData['roomName'] = val;
          },
        ),
        const SizedBox(height: 14.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Grid Row',
                controller: gridRowController,
                focusNode: gridRowFocusNode,
                keyboardType: TextInputType.number,
                isDark: isDark,
                onChanged: (String val) {
                  bufferedData['gridRow'] = int.tryParse(val) ?? 0;
                },
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildTextField(
                label: 'Grid Column',
                controller: gridColumnController,
                focusNode: gridColumnFocusNode,
                keyboardType: TextInputType.number,
                isDark: isDark,
                onChanged: (String val) {
                  bufferedData['gridColumn'] = int.tryParse(val) ?? 0;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Max Voltage (V)',
                controller: maxVoltageController,
                focusNode: maxVoltageFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: errors['maxVoltage'],
                isDark: isDark,
                onChanged: (String val) {
                  bufferedData['maxVoltage'] = double.tryParse(val) ?? 0.0;
                },
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildTextField(
                label: 'Max Allocated Power (W)',
                controller: maxAllocatedPowerController,
                focusNode: maxAllocatedPowerFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                errorText: errors['maxAllocatedPower'],
                isDark: isDark,
                onChanged: (String val) {
                  bufferedData['maxAllocatedPower'] = double.tryParse(val) ?? 0.0;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Country Code (ISO-2)',
                controller: countryCodeController,
                focusNode: countryCodeFocusNode,
                errorText: errors['countryCode'],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(2),
                  UpperCaseTextFormatter(),
                ],
                isDark: isDark,
                onChanged: (String val) {
                  bufferedData['countryCode'] = val.toUpperCase();
                },
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildDropdownField(
                label: 'Location Hierarchy Type',
                focusNode: locationTypeFocusNode,
                value: bufferedData['locationType'] as String,
                errorText: errors['locationType'],
                isDark: isDark,
                items: const [
                  DropdownMenuItem(value: 'site', child: Text('Site')),
                  DropdownMenuItem(value: 'room', child: Text('Room')),
                  DropdownMenuItem(value: 'building', child: Text('Building')),
                  DropdownMenuItem(value: 'invalid-test-option', child: Text('Invalid (Test Only)')),
                ],
                onChanged: (String? val) {
                  if (val != null) {
                    setState(() {
                      bufferedData['locationType'] = val;
                    });
                    _validateAndSaveField('locationType', val);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a stylized form text field group.
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

  /// Builds a stylized dropdown selector.
  Widget _buildDropdownField({
    required String label,
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
              _validateAndSaveField('locationType', bufferedData['locationType']);
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

  /// Builds the committed state JSON panel.
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
                  color: Color(0xFF34A853), // green status color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
