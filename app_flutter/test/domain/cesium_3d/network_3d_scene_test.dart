import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:app_flutter/features/topology/scene_3d_viewport_classes.dart';

void main() {
  late Database db;
  late Network3DScene scene;

  setUpAll(() async {
    // Initialize FFI for SQLite in tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Prepare a temporary database by copying the test database
    final tempDir = Directory.systemTemp.createTempSync('network_3d_scene_test');
    final dbPath = p.join(tempDir.path, 'properties_db.db');
    final sourceDb = File('assets/properties_db.db');
    if (sourceDb.existsSync()) {
      sourceDb.copySync(dbPath);
    }

    db = await databaseFactory.openDatabase(dbPath);

    // Insert a valid model path into the database for the test
    // We use a known asset (e.g. topology_data.json) as a fake 'glb' file just for bytes reading validation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS asset_models (
        id TEXT PRIMARY KEY,
        model_path TEXT NOT NULL
      )
    ''');
    await db.insert('asset_models', {
      'id': 'test_asset',
      'model_path': 'assets/topology_data.json'
    });
  });

  tearDownAll(() async {
    await db.close();
  });

  setUp(() {
    scene = Network3DScene();
  });

  test('loadModel queries DB and successfully loads bytes for a known asset, setting state to loaded', () async {
    // Query the database to retrieve a valid model path for a known asset
    final results = await db.query(
      'asset_models',
      columns: ['model_path'],
      where: 'id = ?',
      whereArgs: ['test_asset'],
    );
    final validModelPath = results.first['model_path'] as String;

    // Load the model
    final success = await scene.loadModel(validModelPath);

    expect(success, isTrue);
    expect(scene.state, equals(ModelRenderState.loaded));
    expect(scene.gltfData, isNotNull);
    expect(scene.gltfData!.isNotEmpty, isTrue);
  });

  test('loadModel fails gracefully and sets state to error for a non-existent path', () async {
    final success = await scene.loadModel('assets/non_existent_model.glb');

    expect(success, isFalse);
    expect(scene.state, equals(ModelRenderState.error));
    expect(scene.gltfData, isNull);
  });

  test('applyPbrMaterials returns false and does not set translucent if state is not loaded', () {
    expect(scene.state, equals(ModelRenderState.unloaded));
    
    final success = scene.applyPbrMaterials();

    expect(success, isFalse);
    expect(scene.isTranslucent, isFalse);
  });
}
