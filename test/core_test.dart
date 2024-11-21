import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/globals.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  tearDownAll(() async {
    locator.reset();
  });
  test('Test env', () async {
    final envFile = File(path.join(Directory.current.path, '.env'));

    if (!envFile.existsSync()) {
      envFile.createSync();
    }

    envFile.writeAsStringSync('''
APP_NAME=testing
''', mode: FileMode.writeOnly);

    final core = Core(
      routers: [],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    expect(core.env('APP_NAME'), 'testing');

    // Clean up
    envFile.deleteSync();
  });
}
