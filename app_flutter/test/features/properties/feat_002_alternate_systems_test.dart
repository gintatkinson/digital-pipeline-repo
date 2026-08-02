import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/properties/view_models/properties_view_model.dart';

/// Realises: [Feat-002/AlternateSystem]
///
/// Mock implementation of [TypeRepository] for test setup.
class _MockTypeRepository implements TypeRepository {
  @override
  Future<Result<List<TypeDescriptor>>> discoverTypes() async {
    return const Result.success([]);
  }

  @override
  Future<Result<TypeDescriptor?>> typeFor(String typeName) async {
    return const Result.success(null);
  }

  @override
  Future<Result<List<(String, String)>>> discoverHierarchy() async {
    return const Result.success([]);
  }
}

/// Realises: [Feat-002/AlternateSystem]
///
/// BDD Acceptance tests for alternate coordinate system lookup and validation.
void main() {
  group('Feat-002 Alternate Coordinate Systems BDD Acceptance Tests', () {
    late PropertiesViewModel viewModel;

    setUp(() {
      viewModel = PropertiesViewModel(_MockTypeRepository());
    });

    test(
      'shouldConvertCoordinatesWhenAlternateSystemAttributeParsed',
      () {
        final validResult = viewModel.lookupEpsgCoordinateSystem('4326');
        expect(validResult.isSuccess, isTrue);
        expect(validResult, isA<Success<String>>());
        expect((validResult as Success<String>).value, equals('EPSG:4326'));

        final validPrefixedResult = viewModel.lookupEpsgCoordinateSystem('EPSG:3857');
        expect(validPrefixedResult.isSuccess, isTrue);
        expect(validPrefixedResult, isA<Success<String>>());
        expect((validPrefixedResult as Success<String>).value, equals('EPSG:3857'));

        final invalidResult = viewModel.lookupEpsgCoordinateSystem('invalid_code');
        expect(invalidResult.isFailure, isTrue);
        expect(invalidResult, isA<Failure<String>>());
        final error = (invalidResult as Failure<String>).error;
        expect(error, isA<SchemaFieldPatternError>());
        final patternError = error as SchemaFieldPatternError;
        expect(patternError.fieldName, equals('epsgCode'));
      },
    );
  });
}
