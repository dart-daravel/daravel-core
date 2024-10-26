import 'dart:io';

import 'package:daravel_core/daravel_core.dart';

import 'package:daravel_core/database/schema.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  setUp(() {
    Directory(path.join(Directory.current.path, 'tests/database-playground'))
        .createSync(recursive: true);

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database: 'tests/database-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
        )
      }
    }));
  });

  tearDown(() {
    Directory(path.join(Directory.current.path, 'tests/database-playground'))
        .deleteSync(recursive: true);
  });

  test('Create simple table Blueprint', () {
    final query = Schema.create('users', (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    expect(query,
        'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);');
  });
}
