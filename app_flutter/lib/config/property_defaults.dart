import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/domain/types.dart';
import 'package:app_flutter/domain/validation.dart';

// TODO(#79): Replace mock fallback initial values with dynamic DB-backed defaults.
// Currently used when widget.initialValues is empty.
const Map<String, dynamic> defaultFallbackInitialValues = {
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

// TODO(#79): Replace mock option display names with dynamic DB-backed mappings.
const Map<String, Map<String, String>> defaultOptionDisplayNames = {
  'locationType': {
    'site': 'Site',
    'room': 'Room',
    'building': 'Building',
    'invalid-test-option': 'Invalid (Test Only)',
  },
};

// TODO(#79): Replace static pairing rules with dynamic schema-driven configuration.
bool defaultShouldPair(AttributeDefinition first, AttributeDefinition second) {
  return (first.key == 'gridRow' && second.key == 'gridColumn') ||
         (first.key == 'maxVoltage' && second.key == 'maxAllocatedPower') ||
         (first.key == 'countryCode' && second.key == 'locationType');
}

// TODO(#79): Replace hardcoded validation with schema-driven validation rules.
String? defaultValidator(String key, String value, Map<String, dynamic> allValues) {
  if (key == 'countryCode') {
    final isCountryValid = validatePhysicalAddress(
      PhysicalAddress(
        address: '',
        postalCode: '',
        state: '',
        city: '',
        countryCode: value,
      ),
    );
    if (!isCountryValid) {
      return 'Must match ISO 2-letter uppercase pattern (e.g. US, FI)';
    }
  } else if (key == 'locationType') {
    final isLocTypeValid = validateLocationType(
      LocationType(
        identity: value,
      ),
    );
    if (!isLocTypeValid) {
      return "Must be 'site', 'room', or 'building'";
    }
  } else if (key == 'maxVoltage' || key == 'maxAllocatedPower') {
    final vText = (key == 'maxVoltage' ? value : allValues['maxVoltage']?.toString()) ?? '0';
    final pText = (key == 'maxAllocatedPower' ? value : allValues['maxAllocatedPower']?.toString()) ?? '0';
    final rName = allValues['roomName']?.toString() ?? '';
    final gRow = int.tryParse(allValues['gridRow']?.toString() ?? '0') ?? 0;
    final gCol = int.tryParse(allValues['gridColumn']?.toString() ?? '0') ?? 0;

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
      return 'Value cannot be negative';
    }
  }
  return null;
}
