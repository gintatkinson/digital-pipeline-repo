import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/database_initializer.dart' as di;

void main() {
  test('Run database initializer', () async {
    await di.main();
  });
}
