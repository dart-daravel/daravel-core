import 'package:daravel_core/daravel_core.dart';

import 'package:test/test.dart';

void main() {
  test('Helpers: substituteVars', () async {
    expect(substituteVars('Hello {{ name }}', {'name': 'John'}), 'Hello John');
  });
}
