import 'dart:convert';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:app_flutter/main.dart' as app_main;
import 'package:app_flutter/app/app.dart';
import 'package:app_flutter/core/theme/theme_controller.dart';
import 'package:app_flutter/core/theme/theme_service.dart';
import 'package:app_flutter/core/theme/text_scaler.dart';
import 'package:app_flutter/core/string_resources.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/data_sources/sqlite_data_source.dart';
import 'package:app_flutter/domain/cesium_3d/camera_controller.dart';
import 'package:app_flutter/features/topology/scene_3d_viewport.dart';
import 'package:app_flutter/domain/database_initializer.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visual Globe TDD verification: HUD, Fly-to-Node, Panning, and Rotation', (WidgetTester tester) async {
    tester.binding.setSurfaceSize(const Size(1920, 1080));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
    });

    await StringResources.load();

    final db = await DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: true);
    addTearDown(() async {
      await db.close();
    });

    final dataSource = SqliteDataSource(db);

    final themeController = ThemeController(SharedPreferencesThemeService());
    await themeController.loadSettings();

    final textScalerController = TextScalerController();
    await textScalerController.load();

    app_main.globalThemeController = themeController;
    app_main.globalTextScalerController = textScalerController;

    Future<void> settle(WidgetTester t) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await t.pump();
      for (int i = 0; i < 50; i++) {
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await t.pump();
      }
    }

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DataSource>.value(value: dataSource),
          ChangeNotifierProvider<ThemeController>.value(value: themeController),
          ChangeNotifierProvider<TextScalerController>.value(value: textScalerController),
        ],
        child: const MyApp(),
      ),
    );

    await settle(tester);

    int attempts = 0;
    while (attempts < 20 && find.byKey(const Key('node_Master_1')).evaluate().isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
      attempts++;
    }

    expect(find.byKey(const Key('node_Master_1')), findsOneWidget, reason: 'Sidebar tree should contain Master_1');

    // Ensure 3D globe is active
    final toggle3dButton = find.byKey(const Key('toggle_3d'));
    if (toggle3dButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(toggle3dButton);
      await tester.tap(toggle3dButton);
      await settle(tester);
    }

    expect(find.byType(Scene3DViewport), findsOneWidget, reason: '3D viewport should be mounted');
    await settle(tester);

    // Capture initial state screenshot
    try {
      await binding.takeScreenshot('../screenshots/camera_initial_hud');
    } catch (_) {}

    final state = tester.state(find.byType(Scene3DViewport)) as dynamic;
    final CameraController controller = state.cameraController as CameraController;
    final double initialLat = controller.current.latitude;
    final double initialLng = controller.current.longitude;

    // Expand Master_1
    final toggleMaster1 = find.byKey(const Key('toggle_Master_1'));
    if (toggleMaster1.evaluate().isNotEmpty) {
      if (find.byKey(const Key('node_Master_1_Child_1')).evaluate().isEmpty) {
        await tester.ensureVisible(toggleMaster1);
        await tester.tap(toggleMaster1);
        await settle(tester);
      }
    }

    // Fly to Node
    final nodeFinder = find.byKey(const Key('node_Master_1_Child_1'));
    print("DEBUG: nodeFinder.evaluate().isNotEmpty = ${nodeFinder.evaluate().isNotEmpty}");
    if (nodeFinder.evaluate().isNotEmpty) {
      await tester.ensureVisible(nodeFinder);
      await tester.tap(nodeFinder);
      await settle(tester);
      await tester.tap(nodeFinder); // Double click simulation
      await settle(tester);
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    // Collapse sidebar and details panels to maximize viewport
    final Finder verticalSplitter = find.byKey(const Key('vertical_splitter'));
    if (verticalSplitter.evaluate().isNotEmpty) {
      await tester.drag(verticalSplitter, const Offset(-1000.0, 0.0));
      await settle(tester);
    }

    final Finder topoSplitter = find.byKey(const Key('topo_splitter'));
    if (topoSplitter.evaluate().isNotEmpty) {
      // Topo splitter is Axis.vertical, so we drag along Y axis to collapse the bottom pane
      await tester.drag(topoSplitter, const Offset(0.0, 1000.0));
      await settle(tester);
    }

    // Verify fly-to-node updates coordinates
    final double postFlyLat = controller.current.latitude;
    final double postFlyLng = controller.current.longitude;
    expect(postFlyLat, isNot(equals(initialLat)), reason: 'Latitude should update after fly-to');
    expect(postFlyLng, isNot(equals(initialLng)), reason: 'Longitude should update after fly-to');
    try {
      await binding.takeScreenshot('../screenshots/camera_fly_to_node');
    } catch (_) {}

    // Drag (Pan gesture)
    final viewport = find.byKey(const Key('scene_3d_viewport_container'));
    await tester.ensureVisible(viewport);
    await tester.drag(viewport, const Offset(100.0, 100.0));
    await settle(tester);

    final stateAfterPan = tester.state(find.byType(Scene3DViewport)) as dynamic;
    final CameraController controllerAfterPan = stateAfterPan.cameraController as CameraController;

    final double postPanLat = controllerAfterPan.current.latitude;
    final double postPanLng = controllerAfterPan.current.longitude;
    expect(postPanLat, isNot(equals(postFlyLat)), reason: 'Latitude should change after pan gesture');
    expect(postPanLng, isNot(equals(postFlyLng)), reason: 'Longitude should change after pan gesture');

    // Ctrl+Drag (Rotate/Heading gesture)
    final double initialHeading = controllerAfterPan.current.heading;
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.drag(viewport, const Offset(-100.0, 0.0));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);

    final stateAfterRotate = tester.state(find.byType(Scene3DViewport)) as dynamic;
    final CameraController controllerAfterRotate = stateAfterRotate.cameraController as CameraController;
    final double postRotateHeading = controllerAfterRotate.current.heading;
    expect(postRotateHeading, isNot(equals(initialHeading)), reason: 'Heading should change after rotate gesture');
    try {
      await binding.takeScreenshot('../screenshots/camera_gesture_rotated');
    } catch (_) {}
  });
}
