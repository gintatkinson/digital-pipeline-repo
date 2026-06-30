import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/type_descriptor.dart';

void main() {
  group('LifecycleState', () {
    test('all six states exist', () {
      expect(LifecycleState.discovered, isA<LifecycleState>());
      expect(LifecycleState.provisioning, isA<LifecycleState>());
      expect(LifecycleState.active, isA<LifecycleState>());
      expect(LifecycleState.degraded, isA<LifecycleState>());
      expect(LifecycleState.decommissioned, isA<LifecycleState>());
      expect(LifecycleState.failed, isA<LifecycleState>());
    });

    test('values have correct order', () {
      expect(LifecycleState.values.length, equals(6));
      expect(LifecycleState.values.first, equals(LifecycleState.discovered));
      expect(LifecycleState.values.last, equals(LifecycleState.failed));
    });
  });
}
