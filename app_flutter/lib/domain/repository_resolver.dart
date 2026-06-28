import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'repository.dart';

class RepositoryResolver {
  static const _defaultConfig = 'assets/persistence-config.json';
  static const _defaultDbAsset = 'assets/properties_db.db';

  static Future<AbstractRepository> resolve({
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

  static Future<SqliteRepositoryAdapter> _createSqliteAdapter({
    String? dbAssetPath,
    bool inMemory = false,
  }) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    if (inMemory) {
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      return SqliteRepositoryAdapter(db);
    }

    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, 'properties_db.db');
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      final assetPath = dbAssetPath ?? _defaultDbAsset;
      final bytes = await rootBundle.load(assetPath);
      await dbFile.writeAsBytes(bytes.buffer.asUint8List());
    }

    final db = await databaseFactory.openDatabase(dbPath);
    return SqliteRepositoryAdapter(db);
  }
}
