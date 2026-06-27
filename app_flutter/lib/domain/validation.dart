import 'reference_frame.dart';
import 'types.dart';

/// Validates a TemporalContext.
/// Property coverage: timestamp, validUntil, velocity
bool validateTemporalContext(TemporalContext context) {
  if (context.timestamp.isEmpty || context.validUntil.isEmpty) {
    return false;
  }
  final ts = DateTime.tryParse(context.timestamp);
  final vu = DateTime.tryParse(context.validUntil);
  if (ts == null || vu == null) {
    return false;
  }
  // Temporal Validity: validUntil cannot be prior to timestamp
  return vu.compareTo(ts) >= 0;
}

/// Validates a PhysicalAddress.
/// Property coverage: address, postalCode, state, city, countryCode
bool validatePhysicalAddress(PhysicalAddress addr) {
  if (addr.countryCode.isEmpty) {
    return false;
  }
  // Country Code Validation: countryCode must match /^[A-Z]{2}$/ regex
  final countryRegex = RegExp(r'^[A-Z]{2}$');
  return countryRegex.hasMatch(addr.countryCode);
}

/// Validates a LocationType.
/// Property coverage: identity
bool validateLocationType(LocationType locType) {
  // Location Identity Validation: LocationType must match 'site', 'room', or 'building'
  const validIdentities = ['site', 'room', 'building'];
  return validIdentities.contains(locType.identity);
}

/// Validates a Rack.
/// Property coverage: maxVoltage, maxAllocatedPower, heightUnits, location
bool validateRack(Rack rack) {
  // Rack Validation: maxVoltage and maxAllocatedPower must be non-negative
  if (rack.maxVoltage < 0 || rack.maxAllocatedPower < 0) {
    return false;
  }
  if (rack.heightUnits < 0) {
    return false;
  }
  return true;
}

/// Validates slot overlap between two ContainedChassis instances.
/// Property coverage: chassisId, startSlot, slotWidth
bool hasSlotOverlap(ContainedChassis chassis1, ContainedChassis chassis2) {
  return chassis1.startSlot < chassis2.startSlot + chassis2.slotWidth &&
      chassis2.startSlot < chassis1.startSlot + chassis1.slotWidth;
}

/// Validates slot allocations for a ChassisContainmentSubsystem to ensure no overlaps.
/// Property coverage: chassis, validateAllocation, validateSlotOverlap
bool validateChassisAllocation(ChassisContainmentSubsystem subsystem) {
  final list = subsystem.chassis;
  for (int i = 0; i < list.length; i++) {
    for (int j = i + 1; j < list.length; j++) {
      if (hasSlotOverlap(list[i], list[j])) {
        return false;
      }
    }
  }
  return true;
}

class ReferenceFrameValidation {
  final bool isValid;
  final ReferenceFrame sanitizedFrame;
  final String sanitizedFrameName;

  const ReferenceFrameValidation({
    required this.isValid,
    required this.sanitizedFrame,
    required this.sanitizedFrameName,
  });
}

String sanitizeFrameName(String name) {
  var result = name.trim();
  if (result.toLowerCase().startsWith('the-')) {
    result = result.substring(4);
  }
  return result.toUpperCase();
}

ReferenceFrameValidation validateReferenceFrame(
  ReferenceFrame frame, {
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

  if (frame.alternateSystem != null && !alternateSystemEnabled) {
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
