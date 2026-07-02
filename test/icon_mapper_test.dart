import 'package:flutter_test/flutter_test.dart';
import 'package:pipeline_app/domain/icon_mapper.dart';

void main() {
  test('resolves known icon names', () {
    expect(IconMapper.resolve('data_object'), isNotNull);
    expect(IconMapper.resolve('folder'), isNotNull);
    expect(IconMapper.resolve('insert_drive_file'), isNotNull);
    expect(IconMapper.resolve('label'), isNotNull);
    expect(IconMapper.resolve('settings'), isNotNull);
    expect(IconMapper.resolve('storage'), isNotNull);
    expect(IconMapper.resolve('cloud'), isNotNull);
    expect(IconMapper.resolve('dns'), isNotNull);
  });

  test('returns fallback for unknown icon name', () {
    final fallback = IconMapper.resolve('data_object');
    expect(IconMapper.resolve('nonexistent_icon_name'), fallback);
  });
}
