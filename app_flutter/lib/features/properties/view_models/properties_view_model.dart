import 'package:flutter/material.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

class PropertiesViewModel extends ChangeNotifier {
  PropertiesViewModel(this._dataSource);
  final DataSource _dataSource;

  TypeDescriptor? _currentType;
  List<FieldDescriptor> get fields => _currentType?.fields ?? [];
  bool get hasType => _currentType != null;

  Future<void> loadType(String typeName) async {
    _currentType = await _dataSource.typeFor(typeName);
    notifyListeners();
  }
}
