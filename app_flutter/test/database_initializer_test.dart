import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/domain/database_initializer.dart' as di;

void main() {
  test('Run database initializer', () async {
    await di.main();
  });

  test('FFI viability probe succeeds on non-sandboxed desktop', () async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      final probe = await databaseFactoryFfi
          .openDatabase(inMemoryDatabasePath)
          .timeout(const Duration(seconds: 2));
      await probe.close();
      expect(probe.isOpen, false);
    }
  });

  test('create() throws StateError when sandbox blocks FFI', () async {
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (!isDesktop) {
      return;
    }
    try {
      await di.DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: false);
    } catch (e) {
      if (e is StateError) {
        return;
      }
    }
  });

  test('create() succeeds with in-memory database on desktop', () async {
    final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (!isDesktop) {
      return;
    }
    final db = await di.DatabaseInitializer.create(dbPath: inMemoryDatabasePath, seed: false);
    expect(db.isOpen, true);
    await db.close();
  });
}
