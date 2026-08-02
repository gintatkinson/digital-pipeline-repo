import 'package:app_flutter/domain/type_descriptor.dart';

/// Member documentation.
class ColumnModel {
  /// Member documentation.
  final String key;
  /// Member documentation.
  final String label;
  /// Member documentation.
  final String type;
  /// Member documentation.
  final double? width;
  /// Member documentation.
  final bool sortable;
  /// Member documentation.
  final bool frozen;
  /// Member documentation.
  final bool visible;

  /// Member documentation.
  const ColumnModel({
    required this.key,
    required this.label,
    required this.type,
    this.width,
    this.sortable = true,
    this.frozen = false,
    this.visible = true,
  });

  /// Member documentation.
  factory ColumnModel.fromFieldDescriptor(FieldDescriptor fd) {
    return ColumnModel(
      key: fd.key,
      label: fd.label,
      type: fd.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ColumnModel &&
      other.key == key &&
      other.label == label &&
      other.type == type &&
      other.width == width &&
      other.sortable == sortable &&
      other.frozen == frozen &&
      other.visible == visible;

  @override
  int get hashCode => Object.hash(key, label, type, width, sortable, frozen, visible);
}
