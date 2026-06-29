import 'type_descriptor.dart';

/// Abstract interface for a swappable data backend.
///
/// Implementations: [SqliteDataSource], [FirebaseDataSource], [GrpcDataSource].
/// The app selects one at startup and discovers all type schemas from it.
abstract class DataSource {
  /// Human-readable name, e.g. "sqlite", "firebase", "grpc".
  String get name;

  /// Discover all object types known to this data source.
  ///
  /// Returns one [TypeDescriptor] per type. The client uses these to
  /// render the sidebar tree, property forms, and tab tables. Adding
  /// a new type to the data source automatically makes it appear in
  /// the UI — no code change required.
  Future<List<TypeDescriptor>> discoverTypes();

  /// Get the [TypeDescriptor] for a specific type by its [typeName].
  ///
  /// Returns null if the type is not known to this data source.
  Future<TypeDescriptor?> typeFor(String typeName);

  /// Discover the tree hierarchy: parent-child relationships.
  ///
  /// Returns a list of (parentTypeName, childTypeName) pairs.
  Future<List<(String, String)>> discoverHierarchy();
}
