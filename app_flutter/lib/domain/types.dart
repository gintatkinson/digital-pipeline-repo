class Velocity {
  final double vNorth;
  final double vEast;
  final double vUp;

  Velocity({
    required this.vNorth,
    required this.vEast,
    required this.vUp,
  });

  factory Velocity.fromJson(Map<String, dynamic> json) {
    return Velocity(
      vNorth: (json['vNorth'] as num).toDouble(),
      vEast: (json['vEast'] as num).toDouble(),
      vUp: (json['vUp'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vNorth': vNorth,
      'vEast': vEast,
      'vUp': vUp,
    };
  }
}

class TemporalContext {
  final String timestamp;
  final String validUntil;
  final Velocity velocity;

  TemporalContext({
    required this.timestamp,
    required this.validUntil,
    required this.velocity,
  });

  factory TemporalContext.fromJson(Map<String, dynamic> json) {
    return TemporalContext(
      timestamp: json['timestamp'] as String,
      validUntil: json['validUntil'] as String,
      velocity: Velocity.fromJson(json['velocity'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'validUntil': validUntil,
      'velocity': velocity.toJson(),
    };
  }
}

class PhysicalAddress {
  final String address;
  final String postalCode;
  final String state;
  final String city;
  final String countryCode;

  PhysicalAddress({
    required this.address,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.countryCode,
  });

  factory PhysicalAddress.fromJson(Map<String, dynamic> json) {
    return PhysicalAddress(
      address: json['address'] as String,
      postalCode: json['postalCode'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      countryCode: json['countryCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'postalCode': postalCode,
      'state': state,
      'city': city,
      'countryCode': countryCode,
    };
  }
}

class LocationType {
  final String identity; // 'site' | 'room' | 'building'

  LocationType({
    required this.identity,
  });

  factory LocationType.fromJson(Map<String, dynamic> json) {
    return LocationType(
      identity: json['identity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
    };
  }
}

class LocationHierarchy {
  final String id;
  final String name;
  final LocationType type;
  final LocationHierarchy? parent;

  LocationHierarchy({
    required this.id,
    required this.name,
    required this.type,
    this.parent,
  });

  factory LocationHierarchy.fromJson(Map<String, dynamic> json) {
    return LocationHierarchy(
      id: json['id'] as String,
      name: json['name'] as String,
      type: LocationType.fromJson(json['type'] as Map<String, dynamic>),
      parent: json['parent'] != null
          ? LocationHierarchy.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toJson(),
      if (parent != null) 'parent': parent!.toJson(),
    };
  }
}

class RackLocation {
  final String roomName;
  final int gridRow;
  final int gridColumn;

  RackLocation({
    required this.roomName,
    required this.gridRow,
    required this.gridColumn,
  });

  factory RackLocation.fromJson(Map<String, dynamic> json) {
    return RackLocation(
      roomName: json['roomName'] as String,
      gridRow: (json['gridRow'] as num).toInt(),
      gridColumn: (json['gridColumn'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'gridRow': gridRow,
      'gridColumn': gridColumn,
    };
  }
}

class Rack {
  final double maxVoltage;
  final double maxAllocatedPower;
  final int heightUnits;
  final RackLocation location;

  Rack({
    required this.maxVoltage,
    required this.maxAllocatedPower,
    required this.heightUnits,
    required this.location,
  });

  factory Rack.fromJson(Map<String, dynamic> json) {
    return Rack(
      maxVoltage: (json['maxVoltage'] as num).toDouble(),
      maxAllocatedPower: (json['maxAllocatedPower'] as num).toDouble(),
      heightUnits: (json['heightUnits'] as num).toInt(),
      location: RackLocation.fromJson(json['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxVoltage': maxVoltage,
      'maxAllocatedPower': maxAllocatedPower,
      'heightUnits': heightUnits,
      'location': location.toJson(),
    };
  }
}

class ContainedChassis {
  final String chassisId;
  final int startSlot;
  final int slotWidth;

  ContainedChassis({
    required this.chassisId,
    required this.startSlot,
    required this.slotWidth,
  });

  bool validateSlotOverlap(ContainedChassis other) {
    return startSlot < other.startSlot + other.slotWidth &&
        other.startSlot < startSlot + slotWidth;
  }

  factory ContainedChassis.fromJson(Map<String, dynamic> json) {
    return ContainedChassis(
      chassisId: json['chassisId'] as String,
      startSlot: (json['startSlot'] as num).toInt(),
      slotWidth: (json['slotWidth'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassisId': chassisId,
      'startSlot': startSlot,
      'slotWidth': slotWidth,
    };
  }
}

class ChassisContainmentSubsystem {
  final List<ContainedChassis> chassis;

  ChassisContainmentSubsystem({
    required this.chassis,
  });

  bool validateAllocation() {
    for (int i = 0; i < chassis.length; i++) {
      for (int j = i + 1; j < chassis.length; j++) {
        if (chassis[i].validateSlotOverlap(chassis[j])) {
          return false;
        }
      }
    }
    return true;
  }

  factory ChassisContainmentSubsystem.fromJson(Map<String, dynamic> json) {
    return ChassisContainmentSubsystem(
      chassis: (json['chassis'] as List<dynamic>)
          .map((item) => ContainedChassis.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chassis': chassis.map((item) => item.toJson()).toList(),
    };
  }
}
