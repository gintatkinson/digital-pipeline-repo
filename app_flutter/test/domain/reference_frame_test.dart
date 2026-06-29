import 'package:app_flutter/domain/reference_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AstronomicalBody', () {
    test('enum values exist', () {
      expect(AstronomicalBody.values, hasLength(3));
      expect(AstronomicalBody.earth, isA<AstronomicalBody>());
      expect(AstronomicalBody.moon, isA<AstronomicalBody>());
      expect(AstronomicalBody.mars, isA<AstronomicalBody>());
    });
  });

  group('ReferenceFrame', () {
    const marsFrame = ReferenceFrame(astronomicalBody: AstronomicalBody.mars);
    const earthFrame = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
    test('constructor defaults geodeticDatum to wgs-84', () {
      expect(marsFrame.geodeticDatum, 'wgs-84');
      expect(earthFrame.geodeticDatum, 'wgs-84');
    });

    test('constructor accepts optional alternateSystem', () {
      const frame = ReferenceFrame(
        astronomicalBody: AstronomicalBody.moon,
        alternateSystem: 'IAU',
      );
      expect(frame.alternateSystem, 'IAU');
    });

    test('constructor accepts custom geodeticDatum', () {
      const frame = ReferenceFrame(
        astronomicalBody: AstronomicalBody.earth,
        geodeticDatum: 'nad-83',
      );
      expect(frame.geodeticDatum, 'nad-83');
    });

    test('alternateSystem defaults to null', () {
      expect(earthFrame.alternateSystem, isNull);
    });

    test('const constructor works', () {
      const frame = ReferenceFrame(astronomicalBody: AstronomicalBody.mars);
      expect(frame, isA<ReferenceFrame>());
    });

    group('fromJson / toJson round-trip', () {
      test('produces equal map', () {
        final frame = ReferenceFrame(astronomicalBody: AstronomicalBody.mars);
        final json = frame.toJson();
        final restored = ReferenceFrame.fromJson(json);
        expect(restored, equals(frame));
      });

      test('with all fields', () {
        final frame = ReferenceFrame(
          astronomicalBody: AstronomicalBody.moon,
          alternateSystem: 'IAU',
          geodeticDatum: 'nad-83',
        );
        final json = frame.toJson();
        final restored = ReferenceFrame.fromJson(json);
        expect(restored, equals(frame));
      });

      test('with alternateSystem null', () {
        final json = {
          'astronomicalBody': 'earth',
          'geodeticDatum': 'wgs-84',
        };
        final frame = ReferenceFrame.fromJson(json);
        expect(frame.alternateSystem, isNull);
        expect(frame.astronomicalBody, AstronomicalBody.earth);
        expect(frame.geodeticDatum, 'wgs-84');
      });

      test('fromJson defaults geodeticDatum to wgs-84 when missing', () {
        final json = {
          'astronomicalBody': 'mars',
        };
        final frame = ReferenceFrame.fromJson(json);
        expect(frame.geodeticDatum, 'wgs-84');
      });

      test('serializes astronomicalBody as name string', () {
        final frame = ReferenceFrame(astronomicalBody: AstronomicalBody.mars);
        final json = frame.toJson();
        expect(json['astronomicalBody'], 'mars');
      });

      test('omits alternateSystem from json when null', () {
        final frame = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        final json = frame.toJson();
        expect(json.containsKey('alternateSystem'), false);
      });
    });

    group('value equality', () {
      test('same fields are equal', () {
        const a = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        const b = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        expect(a, equals(b));
      });

      test('different astronomicalBody is not equal', () {
        expect(marsFrame, isNot(equals(earthFrame)));
      });

      test('different geodeticDatum is not equal', () {
        const defaultFrame = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        const customFrame =
            ReferenceFrame(astronomicalBody: AstronomicalBody.earth, geodeticDatum: 'nad-83');
        expect(defaultFrame, isNot(equals(customFrame)));
      });

      test('different alternateSystem is not equal', () {
        const withSystem =
            ReferenceFrame(astronomicalBody: AstronomicalBody.earth, alternateSystem: 'IAU');
        expect(earthFrame, isNot(equals(withSystem)));
      });

      test('non-identical fields are not equal', () {
        final a = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        final b = ReferenceFrame(astronomicalBody: AstronomicalBody.mars);
        expect(identical(a, b), isFalse);
        expect(a, isNot(equals(b)));
      });

      test('identical instances are equal', () {
        final a = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        final b = a;
        expect(identical(a, b), isTrue);
        expect(a, equals(b));
      });
    });

    group('hashCode', () {
      test('consistent with equals (same fields)', () {
        const a = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        const b = ReferenceFrame(astronomicalBody: AstronomicalBody.earth);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different objects have different hashCodes', () {
        expect(earthFrame.hashCode, isNot(equals(marsFrame.hashCode)));
      });

      test('consistent across multiple calls', () {
        final hash = earthFrame.hashCode;
        expect(earthFrame.hashCode, equals(hash));
        expect(earthFrame.hashCode, equals(hash));
      });
    });

    group('copyWith', () {
      test('returns equal instance when no args', () {
        expect(earthFrame.copyWith(), equals(earthFrame));
      });

      test('overrides astronomicalBody', () {
        final modified = earthFrame.copyWith(astronomicalBody: AstronomicalBody.mars);
        expect(modified.astronomicalBody, AstronomicalBody.mars);
        expect(modified.alternateSystem, earthFrame.alternateSystem);
        expect(modified.geodeticDatum, earthFrame.geodeticDatum);
      });

      test('overrides alternateSystem', () {
        final modified = earthFrame.copyWith(alternateSystem: 'IAU');
        expect(modified.alternateSystem, 'IAU');
        expect(modified.astronomicalBody, earthFrame.astronomicalBody);
        expect(modified.geodeticDatum, earthFrame.geodeticDatum);
      });

      test('overrides geodeticDatum', () {
        final modified = earthFrame.copyWith(geodeticDatum: 'nad-83');
        expect(modified.geodeticDatum, 'nad-83');
        expect(modified.astronomicalBody, earthFrame.astronomicalBody);
        expect(modified.alternateSystem, earthFrame.alternateSystem);
      });

      test('overrides all fields simultaneously', () {
        final modified = earthFrame.copyWith(
          astronomicalBody: AstronomicalBody.moon,
          alternateSystem: 'IAU',
          geodeticDatum: 'nad-83',
        );
        expect(modified.astronomicalBody, AstronomicalBody.moon);
        expect(modified.alternateSystem, 'IAU');
        expect(modified.geodeticDatum, 'nad-83');
      });

      test('returns new instance (not same reference)', () {
        expect(earthFrame.copyWith(), isNot(same(earthFrame)));
      });
    });

    group('toString', () {
      test('contains field values', () {
        final str = earthFrame.toString();
        expect(str, contains('astronomicalBody'));
        expect(str, contains('AstronomicalBody.earth'));
        expect(str, contains('geodeticDatum'));
      });
    });
  });
}
