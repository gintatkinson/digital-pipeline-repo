import 'package:flutter/material.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// View model that loads a [TypeDescriptor] from the data source and exposes
/// its fields for use by the property grid.
class PropertiesViewModel extends ChangeNotifier {
  PropertiesViewModel(this._dataSource);
  final DataSource _dataSource;

  TypeDescriptor? _currentType;

  /// The fields of the currently loaded type, or an empty list.
  List<FieldDescriptor> get fields => _currentType?.fields ?? [];

  /// Whether a type has been loaded.
  bool get hasType => _currentType != null;

  /// Loads the type identified by [typeName] from the data source and
  /// notifies listeners.
  Future<void> loadType(String typeName) async {
    _currentType = await _dataSource.typeFor(typeName);
    notifyListeners();
  }
}
