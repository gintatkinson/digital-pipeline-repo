import 'package:flutter/foundation.dart';
import 'package:pipeline_app/domain/repository.dart';
import 'package:pipeline_app/domain/type_descriptor.dart';

/// ViewModel for the detail panel, consuming [Repository].
class DetailViewModel extends ChangeNotifier {
  final Repository _repository;

  String? _nodeId;
  TypeDescriptor? _typeDescriptor;
  Map<String, dynamic> _properties = {};
  final Map<String, List<Map<String, dynamic>>> _children = {};
  String? _error;
  int _loadIndex = 0;
  bool _isLoading = false;
  bool _disposed = false;

  DetailViewModel(this._repository);

  List<FieldDescriptor> get fields {
    if (_typeDescriptor == null) return [];
    final sorted = List<FieldDescriptor>.from(_typeDescriptor!.fields);
    sorted.sort((a, b) {
      final cmp = a.sectionOrder.compareTo(b.sectionOrder);
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    });
    return sorted;
  }

  Map<String, List<FieldDescriptor>> get sections {
    final result = <String, List<FieldDescriptor>>{};
    for (final field in fields) {
      if (field.sectionLabel != null) {
        result.putIfAbsent(field.sectionLabel!, () => []).add(field);
      }
    }
    return result;
  }

  String? get error => _error;

  bool get isLoading => _isLoading;

  Map<String, dynamic> get properties => _properties;

  List<TypeRelationDescriptor> get childRelations =>
      _typeDescriptor?.childTypes ?? [];

  Map<String, List<Map<String, dynamic>>> get children => _children;

  Future<void> loadNode(String typeName, String nodeId) async {
    _nodeId = nodeId;
    _error = null;
    _isLoading = true;
    final thisIndex = ++_loadIndex;
    try {
      _typeDescriptor = await _repository.typeFor(typeName);
      if (_loadIndex != thisIndex) return;
      final props = await _repository.fetchProperties(nodeId);
      if (_loadIndex != thisIndex) return;
      _properties = props ?? {};
      final newChildren = <String, List<Map<String, dynamic>>>{};
      if (_typeDescriptor != null) {
        for (final relation in _typeDescriptor!.childTypes) {
          final kids = await _repository.fetchChildren(nodeId, relation.relationName);
          if (_loadIndex != thisIndex) return;
          newChildren[relation.relationName] = kids;
        }
      }
      if (_loadIndex != thisIndex) return;
      _children
        ..clear()
        ..addAll(newChildren);
    } catch (e) {
      if (_loadIndex != thisIndex) return;
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> saveProperties(Map<String, dynamic> data) async {
    if (_nodeId == null) return;
    await _repository.saveProperties(_nodeId!, data);
    _properties = data;
    if (!_disposed) {
      notifyListeners();
    }
  }
}
