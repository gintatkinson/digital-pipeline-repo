import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data_source.dart';
import 'data_sources/fallback_data_source.dart';
import 'data_sources/sqlite_data_source.dart';
import 'repository.dart';

class RepositoryResolver {
  static const _defaultConfig = 'assets/persistence-config.json';
  static const _defaultDbAsset = 'assets/properties_db.db';

  static Future<(AbstractRepository, DataSource)> resolve({
    String? configPath,
    String? dbAssetPath,
    bool sqliteInMemory = false,
  }) async {
    final path = configPath ?? _defaultConfig;
    String type = 'sqlite';

    try {
      final configJson = await rootBundle.loadString(path);
      final config = jsonDecode(configJson) as Map<String, dynamic>;
      type = config['repository_type'] as String? ?? 'sqlite';
    } catch (_) {
    }

    switch (type) {
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

      if (!await dbFile.exists()) {
        final assetPath = dbAssetPath ?? _defaultDbAsset;
        final bytes = await rootBundle.load(assetPath);
        await dbFile.writeAsBytes(bytes.buffer.asUint8List());
      }

      db = await databaseFactory.openDatabase(dbPath);
    }

    int typeCount = 0;
    try {
      typeCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM type_definitions'),
      ) ?? 0;
    } catch (_) {
      // metadata tables may not exist in pre-built DB
    }
    final DataSource dataSource = typeCount > 0
        ? SqliteDataSource(db)
        : FallbackDataSource();

    return (SqliteRepositoryAdapter(db), dataSource);
  }
}
