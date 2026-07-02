import 'type_descriptor.dart';

/// Abstract contract for all data backends.
///
/// Implementations (SQLite, in-memory, remote) must provide schema
/// discovery, instance browsing, and CRUD operations. No assumptions
/// about storage format or transport — only typed Dart contracts.
///
/// [discoverTypes] and [discoverInstances] power the sidebar tree and
/// type registry. [fetchProperties] and [saveProperties] drive the
/// [PropertyGrid]. [fetchChildren] feeds the [TablePanel] tabs.
abstract class DataSource {
  /// Human-readable identifier for logging and debugging.
  String get name;

  /// Returns all type schemas known to the backend.
  Future<List<TypeDescriptor>> discoverTypes();

  /// Returns the schema for [typeName], or `null` if unknown.
  Future<TypeDescriptor?> typeFor(String typeName);

  /// Returns all concrete nodes across all types.
  Future<List<InstanceDescriptor>> discoverInstances();

  /// Returns the current property map for [nodeId], or `null` if absent.
  Future<Map<String, dynamic>?> fetchProperties(String nodeId);

  /// Persists the complete property map for [nodeId].
  ///
  /// Replace semantics — previous values are overwritten. Implementations
  /// must be idempotent for the same [nodeId] and [data] pair.
  Future<void> saveProperties(String nodeId, Map<String, dynamic> data);

  /// Returns child entries for [nodeId] via the named [relationName].
  ///
  /// Each list entry is a map with at least an `id` key plus
  /// relation-specific payload columns.
  Future<List<Map<String, dynamic>>> fetchChildren(
    String nodeId,
    String relationName,
  );

  /// Releases any resources held by the data source (e.g. database
  /// connections, network clients). After calling [close] the source
  /// must not be used.
  void close();
}
