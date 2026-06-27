enum AstronomicalBody { earth, moon, mars }

class ReferenceFrame {
  final AstronomicalBody astronomicalBody;
  final String? alternateSystem;
  final String geodeticDatum;

  const ReferenceFrame({
    required this.astronomicalBody,
    this.alternateSystem,
    this.geodeticDatum = 'wgs-84',
  });

  factory ReferenceFrame.fromJson(Map<String, dynamic> json) {
    return ReferenceFrame(
      astronomicalBody:
          AstronomicalBody.values.firstWhere((e) => e.name == json['astronomicalBody'] as String),
      alternateSystem: json['alternateSystem'] as String?,
      geodeticDatum: json['geodeticDatum'] as String? ?? 'wgs-84',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'astronomicalBody': astronomicalBody.name,
      if (alternateSystem != null) 'alternateSystem': alternateSystem,
      'geodeticDatum': geodeticDatum,
    };
  }

  ReferenceFrame copyWith({
    AstronomicalBody? astronomicalBody,
    String? alternateSystem,
    String? geodeticDatum,
  }) {
    return ReferenceFrame(
      astronomicalBody: astronomicalBody ?? this.astronomicalBody,
      alternateSystem: alternateSystem ?? this.alternateSystem,
      geodeticDatum: geodeticDatum ?? this.geodeticDatum,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReferenceFrame) return false;
    return astronomicalBody == other.astronomicalBody &&
        alternateSystem == other.alternateSystem &&
        geodeticDatum == other.geodeticDatum;
  }

  @override
  int get hashCode {
    return Object.hash(astronomicalBody, alternateSystem, geodeticDatum);
  }

  @override
  String toString() {
    return 'ReferenceFrame(astronomicalBody: $astronomicalBody, alternateSystem: $alternateSystem, geodeticDatum: $geodeticDatum)';
  }
}
