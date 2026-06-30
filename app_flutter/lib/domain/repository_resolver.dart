import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data_source.dart';
import 'data_sources/fallback_data_source.dart';
import 'data_sources/firebase_data_source.dart';
import 'data_sources/sqlite_data_source.dart';
import 'repository.dart';

class RepositoryResolver {
  static const _defaultConfig = 'assets/persistence-config.json';
  static const _defaultDbAsset = 'assets/properties_db.db';

  static const _defaultEmulatorHost = 'localhost';
  static const _defaultEmulatorPort = 8080;

  static Future<(AbstractRepository, DataSource)> resolve({
    String? configPath,
    String? dbAssetPath,
    bool sqliteInMemory = false,
    String? dataSourceType,
    bool useEmulator = true,
  }) async {
    String type = dataSourceType ?? 'sqlite';

    // If no explicit type, try reading from config file
    if (dataSourceType == null) {
      final path = configPath ?? _defaultConfig;
      try {
        final configJson = await rootBundle.loadString(path);
        final config = jsonDecode(configJson) as Map<String, dynamic>;
        type = config['repository_type'] as String? ?? 'sqlite';
      } catch (_) {}
    }

    switch (type) {
      case 'firebase':
        return _createFirebaseAdapter(useEmulator: useEmulator);
      case 'sqlite':
        return _createSqliteAdapter(
          dbAssetPath: dbAssetPath,
          inMemory: sqliteInMemory,
        );
      default:
        return _createSqliteAdapter(
          dbAssetPath: dbAssetPath,
          inMemory: sqliteInMemory,
        );
    }
  }

  static Future<(FirebaseRepositoryAdapter, FirebaseDataSource)> _createFirebaseAdapter({
    bool useEmulator = true,
  }) async {
    await Firebase.initializeApp();
    final firestore = FirebaseFirestore.instance;
    if (useEmulator) {
      firestore.useFirestoreEmulator(_defaultEmulatorHost, _defaultEmulatorPort);
    }
    return (FirebaseRepositoryAdapter(firestore), FirebaseDataSource(firestore));
  }

  static Future<(SqliteRepositoryAdapter, DataSource)> _createSqliteAdapter({
    String? dbAssetPath,
    bool inMemory = false,
  }) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    late final Database db;

    if (inMemory) {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    } else {
      final dir = await getApplicationSupportDirectory();
      final dbPath = p.join(dir.path, 'properties_db.db');
      final dbFile = File(dbPath);

      final assetPath = dbAssetPath ?? _defaultDbAsset;
      final bytes = await rootBundle.load(assetPath);
      await dbFile.writeAsBytes(bytes.buffer.asUint8List());

      db = await databaseFactory.openDatabase(dbPath);
    }

    int typeCount = 0;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) AS c FROM type_definitions');
      typeCount = result.isNotEmpty ? (result.first['c'] as int? ?? 0) : 0;
    } catch (_) {
      // metadata tables may not exist in pre-built DB
    }
    final DataSource dataSource = typeCount > 0
        ? SqliteDataSource(db)
        : FallbackDataSource();

    return (SqliteRepositoryAdapter(db), dataSource);
  }
}
