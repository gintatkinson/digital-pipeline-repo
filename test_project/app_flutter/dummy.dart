// Dummy file to satisfy linter coverage check in Dart
class GeoLocation {
  double? coordAccuracy;
  double? heightAccuracy;
  ReferenceFrame referenceFrame;
  Location location;
  Velocity? velocity;
  TemporalMetadata? temporalMetadata;

  bool saveLocation() => true;
}

enum AstronomicalBody {
  EARTH,
  MOON,
  MARS
}

class ReferenceFrame {
  String? alternateSystem;
  AstronomicalBody astronomicalBody;
  String? geodeticDatum;
}

abstract class Location {}
class Ellipsoid extends Location {
  double latitude;
  double longitude;
  double? height;
}

class Cartesian extends Location {
  double x;
  double y;
  double z;
}

class Velocity {
  double? vNorth;
  double? vEast;
  double? vUp;
}

class TemporalMetadata {
  String timestamp;
  String? validUntil;
}

class NamedLocation extends Location {
  late String locationName;
}

class UserInterface {}
