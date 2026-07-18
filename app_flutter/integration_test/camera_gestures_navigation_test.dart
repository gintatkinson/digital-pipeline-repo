import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:app_flutter/domain/cesium_3d/tile_fetcher.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visual Globe TDD verification: HUD, Fly-to-Node, Panning, and Rotation', (WidgetTester tester) async {
    tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      TileFetcher.urlOverride = null;
    });

    // Set local tile file override to verify tile rendering visually
    final String currentDir = Directory.current.path;
    final File localTile = File('$currentDir/test/topology/goldens/exaggerated_fuji_node.png');
    if (localTile.existsSync()) {
      TileFetcher.urlOverride = 'file://${localTile.absolute.path}';
    }

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

    Future<void> takeScreenshot(String name) async {
      final String screenshotDir = Platform.environment['SCREENSHOT_DIR'] ?? '/Users/perkunas/jail/digital-pipeline-repo/screenshots';
      final File file = File('$screenshotDir/$name.png');
      file.parent.createSync(recursive: true);
      final RenderRepaintBoundary boundary = tester.renderObject(find.byType(RepaintBoundary).first);
      final ui.Image image = (await tester.runAsync<ui.Image>(() => boundary.toImage()))!;
      final ByteData? byteData = await tester.runAsync<ByteData?>(() => image.toByteData(format: ui.ImageByteFormat.png));
      file.writeAsBytesSync(byteData!.buffer.asUint8List());
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
    await takeScreenshot('camera_initial_hud');

    final state = tester.state(find.byType(Scene3DViewport)) as dynamic;
    final CameraController controller = state.cameraController as CameraController;
    final double initialLat = controller.current.latitude;
    final double initialLng = controller.current.longitude;

    // Double-tap sidebar node (fly to node)
    final nodeFinder = find.byKey(const Key('node_Master_1_Child_1'));
    await tester.ensureVisible(nodeFinder);
    await tester.tap(nodeFinder);
    await tester.pump();
    await tester.tap(nodeFinder); // Double click simulation
    await settle(tester);

    // Verify fly-to-node updates coordinates
    final double postFlyLat = controller.current.latitude;
    final double postFlyLng = controller.current.longitude;
    expect(postFlyLat, isNot(equals(initialLat)), reason: 'Latitude should update after fly-to');
    expect(postFlyLng, isNot(equals(initialLng)), reason: 'Longitude should update after fly-to');
    await takeScreenshot('camera_fly_to_node');

    // Drag (Pan gesture)
    final viewport = find.byKey(const Key('scene_3d_viewport_container'));
    await tester.drag(viewport, const Offset(-50.0, 0.0));
    await settle(tester);

    final double postDragLng = controller.current.longitude;
    expect(postDragLng, isNot(equals(postFlyLng)), reason: 'Longitude should change after pan drag gesture');

    // Ctrl+Drag (Rotate gesture)
    final double initialHeading = controller.current.heading;
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.drag(viewport, const Offset(-100.0, 0.0));
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle(tester);

    final double postRotateHeading = controller.current.heading;
    expect(postRotateHeading, isNot(equals(initialHeading)), reason: 'Heading should change after rotate gesture');
    await takeScreenshot('camera_gesture_rotated');
  });
}
