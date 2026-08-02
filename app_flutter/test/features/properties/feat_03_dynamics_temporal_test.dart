import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/data_source.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/features/properties/view_models/properties_view_model.dart';

/// Realises: [Feat-03/RateOfChange]
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

/// Realises: [Feat-03/RateOfChange]
///
/// BDD Acceptance tests for temporal boundary validation in dynamic properties.
void main() {
  group('Feat-03 Dynamics Temporal BDD Acceptance Tests', () {
    late PropertiesViewModel viewModel;

    setUp(() {
      viewModel = PropertiesViewModel(_MockTypeRepository());
    });

    test(
      'shouldReturnSchemaFieldRangeErrorWhenValidUntilPrecedesTimestamp',
      () {
        final equalTimeResult = viewModel.validateTemporalBoundary(
          timestamp: 1000,
          validUntil: 1000,
        );
        expect(equalTimeResult.isFailure, isTrue);
        expect(equalTimeResult, isA<Failure<void>>());
        final equalErr = (equalTimeResult as Failure<void>).error;
        expect(equalErr, isA<SchemaFieldRangeError>());
        final rangeError = equalErr as SchemaFieldRangeError;
        expect(rangeError.fieldName, equals('validUntil'));

        final precedingTimeResult = viewModel.validateTemporalBoundary(
          timestamp: 1000,
          validUntil: 500,
        );
        expect(precedingTimeResult.isFailure, isTrue);
        expect(precedingTimeResult, isA<Failure<void>>());
        final precedingErr = (precedingTimeResult as Failure<void>).error;
        expect(precedingErr, isA<SchemaFieldRangeError>());
        expect((precedingErr as SchemaFieldRangeError).fieldName, equals('validUntil'));

        final happyPathResult = viewModel.validateTemporalBoundary(
          timestamp: 1000,
          validUntil: 2000,
        );
        expect(happyPathResult.isSuccess, isTrue);
        expect(happyPathResult, isA<Success<void>>());
      },
    );
  });
}
