import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/action_descriptor.dart';

void main() {
  group('ActionDescriptor', () {
    test('constructs with all required fields', () {
      final a = ActionDescriptor(name: 'reboot', label: 'Reboot', iconName: 'restart');
      expect(a.name, equals('reboot'));
      expect(a.label, equals('Reboot'));
      expect(a.destructive, isFalse);
      expect(a.parameters, isNull);
    });

    test('constructs with parameters', () {
      final param = ActionParameterDescriptor(key: 'reason', label: 'Reason', type: 'string', required: true);
      final a = ActionDescriptor(name: 'deploy', label: 'Deploy', iconName: 'rocket_launch',
          destructive: true, confirmation: 'Deploy to production?', parameters: [param]);
      expect(a.destructive, isTrue);
      expect(a.confirmation, isNotNull);
      expect(a.parameters!.length, equals(1));
      expect(a.parameters!.first.key, equals('reason'));
    });
  });

  group('ActionParameterDescriptor', () {
    test('constructs with all fields', () {
      final p = ActionParameterDescriptor(key: 'k', label: 'L', type: 'string',
          required: true, defaultValue: 'default', enumOptions: ['a', 'b']);
      expect(p.key, equals('k'));
      expect(p.enumOptions!.length, equals(2));
    });
  });
}
