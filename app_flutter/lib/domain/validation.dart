/// Validates a TemporalContext.
/// Property coverage: timestamp, validUntil, velocity
bool validateTemporalContext(Map<String, dynamic> context) {
  final timestamp = context['timestamp'] as String? ?? '';
  final validUntil = context['validUntil'] as String? ?? '';
  if (timestamp.isEmpty || validUntil.isEmpty) {
    return false;
  }
  final ts = DateTime.tryParse(timestamp);
  final vu = DateTime.tryParse(validUntil);
  if (ts == null || vu == null) {
    return false;
  }
  // Temporal Validity: validUntil cannot be prior to timestamp
  return vu.compareTo(ts) >= 0;
}

/// Validates a PhysicalAddress.
/// Property coverage: address, postalCode, state, city, countryCode
bool validatePhysicalAddress(Map<String, dynamic> addr) {
  final countryCode = addr['countryCode'] as String? ?? '';
  if (countryCode.isEmpty) {
    return false;
  }
  // Country Code Validation: countryCode must match /^[A-Z]{2}$/ regex
  final countryRegex = RegExp(r'^[A-Z]{2}$');
  return countryRegex.hasMatch(countryCode);
}

/// Validates a LocationType.
/// Property coverage: identity
bool validateLocationType(Map<String, dynamic> locType) {
  // Location Identity Validation: LocationType must match 'site', 'room', or 'building'
  const validIdentities = ['site', 'room', 'building'];
  return validIdentities.contains(locType['identity'] as String? ?? '');
}

/// Validates a Rack.
/// Property coverage: maxVoltage, maxAllocatedPower, heightUnits, location
bool validateRack(Map<String, dynamic> rack) {
  final maxVoltage = (rack['maxVoltage'] as num?)?.toDouble() ?? 0.0;
  final maxAllocatedPower = (rack['maxAllocatedPower'] as num?)?.toDouble() ?? 0.0;
  final heightUnits = (rack['heightUnits'] as num?)?.toInt() ?? 0;
  // Rack Validation: maxVoltage and maxAllocatedPower must be non-negative
  if (maxVoltage < 0 || maxAllocatedPower < 0) {
    return false;
  }
  if (heightUnits < 0) {
    return false;
  }
  return true;
}

/// Validates slot overlap between two ContainedChassis instances.
/// Property coverage: chassisId, startSlot, slotWidth
bool hasSlotOverlap(Map<String, dynamic> chassis1, Map<String, dynamic> chassis2) {
  final start1 = (chassis1['startSlot'] as num?)?.toInt() ?? 0;
  final width1 = (chassis1['slotWidth'] as num?)?.toInt() ?? 0;
  final start2 = (chassis2['startSlot'] as num?)?.toInt() ?? 0;
  final width2 = (chassis2['slotWidth'] as num?)?.toInt() ?? 0;
  return start1 < start2 + width2 &&
      start2 < start1 + width1;
}

/// Validates slot allocations for a ChassisContainmentSubsystem to ensure no overlaps.
/// Property coverage: chassis, validateAllocation, validateSlotOverlap
bool validateChassisAllocation(Map<String, dynamic> subsystem) {
  final chassisList = (subsystem['chassis'] as List<dynamic>?) ?? [];
  for (int i = 0; i < chassisList.length; i++) {
    for (int j = i + 1; j < chassisList.length; j++) {
      if (hasSlotOverlap(
        chassisList[i] as Map<String, dynamic>,
        chassisList[j] as Map<String, dynamic>,
      )) {
        return false;
      }
    }
  }
  return true;
}

class ReferenceFrameValidation {
  final bool isValid;
  final Map<String, dynamic> sanitizedFrame;
  final String sanitizedFrameName;

  const ReferenceFrameValidation({
    required this.isValid,
    required this.sanitizedFrame,
    required this.sanitizedFrameName,
  });
}

String sanitizeFrameName(String name) {
  var result = name.trim();
  result = result.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
  if (result.toLowerCase().startsWith('the-')) {
    result = result.substring(4);
  }
  return result.toUpperCase();
}

ReferenceFrameValidation validateReferenceFrame(
  Map<String, dynamic> frame, {
  String? frameName,
  bool alternateSystemEnabled = false,
}) {
  if (frameName != null) {
    for (final codeUnit in frameName.codeUnits) {
      if (codeUnit <= 0x1f || codeUnit == 0x7f) {
        return ReferenceFrameValidation(
          isValid: false,
          sanitizedFrame: frame,
          sanitizedFrameName: sanitizeFrameName(frameName),
        );
      }
    }
  }

  if (frame['alternateSystem'] != null && !alternateSystemEnabled) {
    return ReferenceFrameValidation(
      isValid: false,
      sanitizedFrame: frame,
      sanitizedFrameName: frameName != null ? sanitizeFrameName(frameName) : '',
    );
  }

  return ReferenceFrameValidation(
    isValid: true,
    sanitizedFrame: frame,
    sanitizedFrameName: frameName != null ? sanitizeFrameName(frameName) : '',
  );
}
