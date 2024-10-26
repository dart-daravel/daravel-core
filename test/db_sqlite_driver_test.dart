import 'dart:io';

import 'package:daravel_core/daravel_core.dart';

import 'package:daravel_core/database/schema.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  setUpAll(() {
    Directory(path.join(Directory.current.path, 'test/database-playground'))
        .createSync(recursive: true);

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
        )
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(Directory.current.path, 'test/database-playground'))
        .deleteSync(recursive: true);
  });

  test('Create simple table Blueprint', () {
    final query = Schema.create('users_1', (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    expect(query,
        'CREATE TABLE users_1 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);');
  });

  test('Create nullable field table Blueprint', () {
    final query = Schema.create('users_2', (table) {
      table.increments('id');
      table.string('email').nullable();
      table.string('password');
    });

    expect(query,
        'CREATE TABLE users_2 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100), password VARCHAR(100) NOT NULL);');
  });
}
