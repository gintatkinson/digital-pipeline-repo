import 'package:app_flutter/domain/schema.dart';
import 'package:app_flutter/domain/validation.dart';

// TODO(#79): Replace mock fallback initial values with dynamic DB-backed defaults.
// Currently used when widget.initialValues is empty.
const Map<String, dynamic> defaultFallbackInitialValues = {
  'latitude': 37.7749,
  'longitude': -122.4194,
  'altitude': 10,
  'placeName': 'Sector-Alpha',
  'gridRow': 12,
  'gridColumn': 4,
  'maxVoltage': 240.0,
  'maxAllocatedPower': 15000.0,
  'countryCode': 'US',
  'placeType': 'zone',
};

// TODO(#79): Replace mock option display names with dynamic DB-backed mappings.
const Map<String, Map<String, String>> defaultOptionDisplayNames = {
  'placeType': {
    'zone': 'Zone',
    'area': 'Area',
    'cluster': 'Cluster',
    'test-option': 'Test Option',
  },
};

// TODO(#79): Replace static pairing rules with dynamic schema-driven configuration.
bool defaultShouldPair(AttributeDefinition first, AttributeDefinition second) {
  return (first.key == 'gridRow' && second.key == 'gridColumn') ||
         (first.key == 'maxVoltage' && second.key == 'maxAllocatedPower') ||
         (first.key == 'countryCode' && second.key == 'placeType');
}

// TODO(#79): Replace hardcoded validation with schema-driven validation rules.
String? defaultValidator(String key, String value, Map<String, dynamic> allValues) {
  if (key == 'countryCode') {
    final isCountryValid = validatePostalAddress({
      'countryCode': value,
    });
    if (!isCountryValid) {
      return 'Must match ISO 2-letter uppercase pattern (e.g. US, FI)';
    }
  } else if (key == 'placeType') {
    final isLocTypeValid = validatePlaceType({
      'identity': value,
    });
    if (!isLocTypeValid) {
      return "Must be 'zone', 'area', or 'cluster'";
    }
  } else if (key == 'maxVoltage' || key == 'maxAllocatedPower') {
    final vText = (key == 'maxVoltage' ? value : allValues['maxVoltage']?.toString()) ?? '0';
    final pText = (key == 'maxAllocatedPower' ? value : allValues['maxAllocatedPower']?.toString()) ?? '0';
    final rName = allValues['placeName']?.toString() ?? '';
    final gRow = int.tryParse(allValues['gridRow']?.toString() ?? '0') ?? 0;
    final gCol = int.tryParse(allValues['gridColumn']?.toString() ?? '0') ?? 0;

    final double voltageVal = double.tryParse(vText) ?? 0.0;
    final double powerVal = double.tryParse(pText) ?? 0.0;

    final bool isLoadValid = validateLoadSpec({
      'maxVoltage': voltageVal,
      'maxAllocatedPower': powerVal,
      'capacity': 42,
      'placeName': rName,
      'gridRow': gRow,
      'gridColumn': gCol,
    });

    if (!isLoadValid) {
      return 'Value cannot be negative';
    }
  }
  return null;
}
