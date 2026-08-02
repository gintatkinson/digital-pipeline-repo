import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

/// Realises: [Feat-10/PropertiesState]
///
/// Immutable state holder for property panel data.
@immutable
class PropertiesState {
  /// Creates a [PropertiesState].
  const PropertiesState({
    this.currentType,
  });

  /// The currently loaded [TypeDescriptor], or null.
  final TypeDescriptor? currentType;

  /// Creates a copy of this state with updated fields.
  PropertiesState copyWith({
    TypeDescriptor? currentType,
    bool clearCurrentType = false,
  }) {
    return PropertiesState(
      currentType: clearCurrentType ? null : (currentType ?? this.currentType),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertiesState &&
          runtimeType == other.runtimeType &&
          currentType == other.currentType;

  @override
  int get hashCode => currentType.hashCode;
}

/// Realises: [Feat-10/PropertiesViewModel]
///
/// Loads a [TypeDescriptor] from the data source and exposes its fields to the
/// property grid widget.
///
/// Exists to decouple the property grid from the data-fetching logic. Use this
/// view model whenever the property panel needs to display a node's fields.
class PropertiesViewModel extends ChangeNotifier {
  /// Creates a [PropertiesViewModel] with injected [TypeRepository].
  PropertiesViewModel(this._typeRepository);

  final TypeRepository _typeRepository;
  PropertiesState _state = const PropertiesState();
  bool _disposed = false;
  int _requestId = 0;

  /// Current immutable state.
  PropertiesState get state => _state;

  /// The fields of the currently loaded type. Returns an empty list when no
  /// type has been loaded or `loadType` returned `null`.
  List<FieldDescriptor> get fields => _state.currentType?.fields ?? [];

  /// Whether a type has been loaded (i.e., [loadType] completed with a
  /// non-null [TypeDescriptor]).
  bool get hasType => _state.currentType != null;

  /// Fetches the [TypeDescriptor] for [typeName] from the data source and
  /// notifies listeners.
  ///
  /// If the data source returns `null` (unknown type), [_state] is updated with
  /// null type, [fields] becomes empty, and [hasType] becomes false.
  Future<void> loadType(String typeName) async {
    final requestId = ++_requestId;
    final res = await _typeRepository.typeFor(typeName);
    if (_disposed) return;
    if (_requestId != requestId) return;

    switch (res) {
      case Success<TypeDescriptor?>(:final value):
        _state = _state.copyWith(currentType: value, clearCurrentType: value == null);
      case Failure<TypeDescriptor?>():
        _state = _state.copyWith(clearCurrentType: true);
    }
    notifyListeners();
  }

  /// Realises: [Feat-002/AlternateSystem]
  ///
  /// Looks up and validates a spatial coordinate transformation for [epsgCode].
  ///
  /// Returns [Result.success] formatted as `'EPSG:<code_number>'` when [epsgCode]
  /// is valid, or [Result.failure] with a [SchemaFieldPatternError] if the format is invalid.
  Result<String> lookupEpsgCoordinateSystem(String epsgCode) {
    final cleanCode = epsgCode.trim();
    if (cleanCode.isEmpty) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'epsgCode',
          value: epsgCode,
          pattern: r'^\d+$',
        ),
      );
    }
    String codeDigits = cleanCode;
    if (codeDigits.toUpperCase().startsWith('EPSG:')) {
      codeDigits = codeDigits.substring(5).trim();
    }
    final digitRegExp = RegExp(r'^\d+$');
    if (!digitRegExp.hasMatch(codeDigits)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'epsgCode',
          value: epsgCode,
          pattern: r'^\d+$',
        ),
      );
    }
    return Result.success('EPSG:$codeDigits');
  }

  /// Realises: [Feat-03/RateOfChange]
  ///
  /// Validates the temporal boundary between [timestamp] and [validUntil].
  ///
  /// Returns [Result.success] when `validUntil > timestamp`, or [Result.failure]
  /// with a [SchemaFieldRangeError] when `validUntil <= timestamp`.
  Result<void> validateTemporalBoundary({
    required num timestamp,
    required num validUntil,
  }) {
    if (validUntil > timestamp) {
      return const Result.success(null);
    }
    return Result.failure(
      SchemaFieldRangeError(
        fieldName: 'validUntil',
        value: validUntil,
        min: timestamp,
      ),
    );
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

