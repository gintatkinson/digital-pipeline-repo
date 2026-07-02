import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pipeline_app/domain/data_source.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

/// SQLite-backed [Repository] implementation.
///
/// Delegates all operations to the injected [DataSource] without
/// adding business logic. Exposes [db] for test seeding.
class SqliteRepository implements Repository {
  final DataSource _dataSource;

  SqliteRepository(this._dataSource);

  Database get db => (_dataSource as dynamic).db;

  @override
  Future<List<TypeDescriptor>> discoverTypes() => _dataSource.discoverTypes();

  @override
  Future<TypeDescriptor?> typeFor(String typeName) => _dataSource.typeFor(typeName);

  @override
  Future<List<InstanceDescriptor>> discoverInstances() => _dataSource.discoverInstances();

  @override
  Future<Map<String, dynamic>?> fetchProperties(String nodeId) => _dataSource.fetchProperties(nodeId);

  @override
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data) => _dataSource.saveProperties(nodeId, data);

  @override
  Future<List<Map<String, dynamic>>> fetchChildren(String nodeId, String relationName) => _dataSource.fetchChildren(nodeId, relationName);

  @override
  void close() => _dataSource.close();
}
