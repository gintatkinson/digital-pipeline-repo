import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/cesium_3d/cesium_engine.dart';
import 'package:app_flutter/domain/cesium_3d/virtual_camera.dart';
import 'package:app_flutter/features/topology/scene_3d_viewport_classes.dart';

void main() {
  group('VirtualCameraNormalization', () {
    test('toAbsoluteWgs84 converts relative altitude to absolute ECEF coordinates', () {
      final camera = VirtualCamera.raw(
        latitude: 0,
        longitude: 0,
        altitude: 500.0,
        heading: 0,
        pitch: 0,
        roll: 0,
      );

      final absoluteCamera = camera.toAbsoluteWgs84();

      expect(absoluteCamera.altitude, Ellipsoid.wgs84EquatorialRadius + 500.0);
    });

    test('toAbsoluteWgs84 returns unmodified instance if altitude is already absolute', () {
      final camera = VirtualCamera.raw(
        latitude: 0,
        longitude: 0,
        altitude: 10000000.0,
        heading: 0,
        pitch: 0,
        roll: 0,
      );

      final absoluteCamera = camera.toAbsoluteWgs84();

      expect(identical(camera, absoluteCamera), isTrue);
    });
  });

  group('ElevationProvider', () {
    test('getElevation returns 0.0 when inactive', () {
      final provider = const ElevationProvider(isElevationActive: false);
      expect(provider.getElevation(35.3606, 138.7274), 0.0);
      expect(provider.getElevation(0.0, 0.0), 0.0);
    });

    test('getElevation simulates Mount Fuji accurately', () {
      final provider = const ElevationProvider(isElevationActive: true);
      // exact coordinates for Mount Fuji
      final elevation = provider.getElevation(35.3606, 138.7274);
      expect(elevation, 3776.0);
    });

    test('getElevation applies vertical exaggeration correctly', () {
      final provider = const ElevationProvider(
        isElevationActive: true, 
        verticalExaggeration: 2.0,
      );
      final elevation = provider.getElevation(35.3606, 138.7274);
      expect(elevation, 3776.0 * 2.0);
    });
  });

  group('CoordinateTransformer', () {
    test('instantiates with known camera and screen size without errors', () {
      final camera = VirtualCamera.raw(
        latitude: 0,
        longitude: 0,
        altitude: 500.0,
        heading: 0,
        pitch: 0,
        roll: 0,
      );

      expect(() {
        CoordinateTransformer(
          camera: camera,
          viewportSize: const Size(800, 600),
          screenCenter: const Offset(400, 300),
          rotationAngle: 0.0,
          tilt: 0.0,
        );
      }, returnsNormally);
    });

    test('projectWgs84ToScreen horizon culling check (behind Earth)', () {
      final camera = VirtualCamera.raw(
        latitude: 0.0,
        longitude: 0.0,
        altitude: 500000.0, // Above surface
        heading: 0,
        pitch: -90,
        roll: 0,
      );

      final transformer = CoordinateTransformer(
        camera: camera,
        viewportSize: const Size(800, 600),
        screenCenter: const Offset(400, 300),
        rotationAngle: 0.0, // Longitude rotation is negative, so 0 is 0
        tilt: 0.0, // Latitude rotation is negative, so 0 is 0
      );

      // Point on the exact opposite side of the Earth
      final proj = transformer.projectWgs84ToScreen(
        latRad: 0.0, // 0 deg
        lngRad: math.pi, // 180 deg
        heightMeters: 0.0,
        clampToHorizon: false,
      );

      // Z should be negative since it's behind the horizon
      expect(proj.z, lessThan(0.0));
      expect(proj.z, -2.0);
    });

    test('projectWgs84ToScreen direct line of sight to camera lat/lng at surface height', () {
      final camera = VirtualCamera.raw(
        latitude: 0.0,
        longitude: 0.0,
        altitude: 500000.0,
        heading: 0,
        pitch: -90, // Looking straight down
        roll: 0,
      );

      final transformer = CoordinateTransformer(
        camera: camera,
        viewportSize: const Size(800, 600),
        screenCenter: const Offset(400, 300),
        rotationAngle: 0.0,
        tilt: 0.0,
      );

      // Project the point directly beneath the camera
      final proj = transformer.projectWgs84ToScreen(
        latRad: 0.0,
        lngRad: 0.0,
        heightMeters: 0.0,
      );

      // Should project exactly to the center of the screen
      expect(proj.offset.dx, closeTo(400.0, 0.001));
      expect(proj.offset.dy, closeTo(300.0, 0.001));
    });
  });
}
