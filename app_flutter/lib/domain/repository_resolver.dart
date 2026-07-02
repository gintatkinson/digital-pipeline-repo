import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/data_source.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/sqlite_data_source.dart';
import 'package:pipeline_app/domain/data_sources/firebase_data_source.dart';
import 'package:pipeline_app/domain/sqlite_repository.dart';
import 'package:pipeline_app/domain/firebase_repository.dart';
import 'package:pipeline_app/domain/seed_system_data.dart';

/// Resolves the data-access backend at app startup.
///
/// Returns a ([Repository], [DataSource]) pair selected by the
/// [dataSourceType] parameter or auto-detected from the environment.
/// Falls back to SQLite when Firebase initialisation fails.
class RepositoryResolver {
  static Future<(Repository, DataSource)> resolve({
    String dataSourceType = 'sqlite',
    bool useFirebaseEmulator = true,
  }) async {
    if (dataSourceType == 'firebase') {
      try {
        return await _firebase(useEmulator: useFirebaseEmulator);
      } catch (e) {
        debugPrint('Firebase unavailable, falling back to SQLite: $e');
      }
    }
    return _sqlite();
  }

  static Future<(Repository, DataSource)> _firebase({required bool useEmulator}) async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyD-emulator-key',
        appId: '1:123456789:ios:abc123',
        messagingSenderId: '123456789',
        projectId: 'pipeline-dev',
      ),
    );
    final firestore = FirebaseFirestore.instance;
    if (useEmulator) {
      firestore.useFirestoreEmulator('localhost', 8080);
    }
    final ds = FirebaseDataSource(firestore);
    return (FirebaseRepository(ds), ds);
  }

  static Future<(Repository, DataSource)> _sqlite() async {
    sqfliteFfiInit();
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'pipeline.db');
    final db = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
    const seedConfig = SeedConfig(
      typeCount: 8, masterCount: 100, attributesPerType: 50,
      sectionsPerType: 5, relationCountPerType: 3, rowsPerRelation: 90,
    );
    await seedSystemData(db, seedConfig);
    final ds = SqliteDataSource(db);
    return (SqliteRepository(ds), ds);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE type_definition (type_name TEXT PRIMARY KEY, display_name TEXT, icon_name TEXT)');
    await db.execute('CREATE TABLE type_attribute (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name TEXT, attr_key TEXT, label TEXT, attr_type TEXT, section_label TEXT, section_order INTEGER DEFAULT 0, is_required INTEGER DEFAULT 0, min_value REAL, max_value REAL, pattern TEXT, enum_options TEXT, enum_display_names TEXT, default_value TEXT, input_formatters TEXT, UNIQUE(type_name, attr_key))');
    await db.execute('CREATE TABLE type_relation (id INTEGER PRIMARY KEY AUTOINCREMENT, parent_type_name TEXT, relation_name TEXT, child_type_name TEXT, child_label TEXT, UNIQUE(parent_type_name, child_type_name))');
    await db.execute('CREATE TABLE instance (node_id TEXT PRIMARY KEY, data_json TEXT)');
    await db.execute('CREATE TABLE child_entry (id TEXT PRIMARY KEY, parent_node_id TEXT, relation_name TEXT, payload_json TEXT)');
  }
}
