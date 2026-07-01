import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data_source.dart';
import 'data_sources/fallback_data_source.dart';
import 'data_sources/firebase_data_source.dart';
import 'data_sources/sqlite_data_source.dart';
import 'database_initializer.dart';
import 'repository.dart';

/// Resolves the data-access backend at app startup.
///
/// Reads a JSON configuration file (or falls back to defaults) to decide
/// whether to initialise a local SQLite database or connect to Cloud
/// Firestore. Returns a pair of ([AbstractRepository], [DataSource]) that
/// the app uses for all read/write operations and schema discovery.
///
/// Call this once at startup, before any data-dependent widget builds.
/// The resolved pair is then injected via dependency injection or passed
/// through the widget tree. Calling [resolve] multiple times creates
/// separate connections — doing so is not recommended.
class RepositoryResolver {
  static const _defaultConfig = 'assets/persistence-config.json';
  static const _defaultDbAsset = 'assets/properties_db.db';

  static const _defaultEmulatorHost = 'localhost';
  static const _defaultEmulatorPort = 8080;

  /// Resolves and initialises the appropriate backend.
  ///
  /// Determines the backend type from (in priority order):
  /// 1. [dataSourceType] parameter (if non-null)
  /// 2. JSON config file at [configPath] or the default asset path
  /// 3. Falls back to SQLite if neither is available
  ///
  /// For SQLite: copies the bundled database from [dbAssetPath] to the
  /// app support directory (unless [sqliteInMemory] is true). Creates
  /// the tables if they do not exist via [DatabaseInitializer].
  ///
  /// For Firebase: initialises the Firebase app and optionally connects
  /// to the Firestore emulator at [useEmulator].
  ///
  /// Returns a tuple of ([AbstractRepository], [DataSource]) ready for
  /// injection. Throws on network errors (Firebase init) or file I/O
  /// errors (asset copy failure). Always resolves to a non-null pair.
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
        try {
          return await _createFirebaseAdapter(useEmulator: useEmulator);
        } catch (e) {
          debugPrint('Firebase unavailable, falling back to SQLite: $e');
          return _createSqliteAdapter(
            dbAssetPath: dbAssetPath,
            inMemory: sqliteInMemory,
          );
        }
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

  /// Initialies Firebase and returns a Firestore-backed pair.
  ///
  /// Calls [Firebase.initializeApp] first (idempotent if already called).
  /// When [useEmulator] is true, redirects Firestore to the local emulator
  /// at localhost:8080 — useful for development without a real Firebase
  /// project. Throws if Firebase initialisation fails (missing config, etc.).
  static Future<(AbstractRepository, DataSource)> _createFirebaseAdapter({
    bool useEmulator = true,
  }) async {
    await Firebase.initializeApp();
    final firestore = FirebaseFirestore.instance;
    if (useEmulator) {
      firestore.useFirestoreEmulator(_defaultEmulatorHost, _defaultEmulatorPort);
    }
    return (FirebaseRepositoryAdapter(firestore), FirebaseDataSource(firestore));
  }

  /// Initialises SQLite FFI and returns an SQLite-backed pair.
  ///
  /// When [inMemory] is true, creates a transient in-memory database
  /// (data is lost on app restart). Otherwise, copies the asset database
  /// from [dbAssetPath] (or the default asset) to the app support directory
  /// and opens it. Checks for `type_definitions` table to decide between
  /// [SqliteDataSource] (real schema) and [FallbackDataSource] (demo view).
  /// Throws on file I/O errors or database corruption.
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
      if (!await dbFile.exists()) {
        final bytes = await rootBundle.load(assetPath);
        await dbFile.writeAsBytes(bytes.buffer.asUint8List());
      }

      db = await DatabaseInitializer.create(dbPath: dbPath, seed: true);
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
