import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipeline_app/core/text_scaler.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load defaults to 1.0 when no persisted value', () async {
    final scaler = TextScaleController();
    await scaler.load();
    expect(scaler.scale, 1.0);
  });

  test('setScale clamps to valid range', () async {
    final scaler = TextScaleController();
    await scaler.load();

    await scaler.setScale(0.5);
    expect(scaler.scale, 0.7);

    await scaler.setScale(2.0);
    expect(scaler.scale, 1.5);

    await scaler.setScale(1.25);
    expect(scaler.scale, 1.25);
  });

  test('setScale persists and notifies', () async {
    final scaler = TextScaleController();
    await scaler.load();

    var notified = false;
    scaler.addListener(() => notified = true);

    await scaler.setScale(1.3);
    expect(scaler.scale, 1.3);
    expect(notified, true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('text_scale_factor'), 1.3);
  });

  test('no-op on same scale value', () async {
    final scaler = TextScaleController();
    await scaler.load();

    var notifications = 0;
    scaler.addListener(() => notifications++);

    await scaler.setScale(1.0);
    expect(notifications, 0);
  });
}
