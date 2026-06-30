import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/core/app_config.dart';

void main() {
  test('AppConfig.appDisplayName is non-empty', () {
    expect(AppConfig.appDisplayName, isNotEmpty);
  });

  test('AppConfig.appDisplayName equals AppConfig.title', () {
    expect(AppConfig.appDisplayName, equals(AppConfig.title));
  });
}
