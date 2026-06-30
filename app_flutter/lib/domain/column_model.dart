import 'type_descriptor.dart';

class ColumnModel {
  final String key;
  final String label;
  final String type;
  final double? width;
  final bool sortable;
  final bool frozen;
  final bool visible;
  final String? refType;

  const ColumnModel({
    required this.key,
    required this.label,
    required this.type,
    this.width,
    this.sortable = true,
    this.frozen = false,
    this.visible = true,
    this.refType,
  });

  factory ColumnModel.fromFieldDescriptor(FieldDescriptor fd) {
    return ColumnModel(
      key: fd.key,
      label: fd.label,
      type: fd.type,
      refType: fd.refType,
    );
  }
}
