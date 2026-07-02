import 'package:pipeline_app/domain/type_descriptor.dart';

/// Domain-level contract for data access, consumed by ViewModels.
///
/// Implementations delegate to a concrete [DataSource] (SQLite, Firebase)
/// and may add caching, validation, or business logic on top.
abstract class Repository {
  Future<List<TypeDescriptor>> discoverTypes();
  Future<TypeDescriptor?> typeFor(String typeName);
  Future<List<InstanceDescriptor>> discoverInstances();
  Future<Map<String, dynamic>?> fetchProperties(String nodeId);
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> fetchChildren(String nodeId, String relationName);
  void close();
}
