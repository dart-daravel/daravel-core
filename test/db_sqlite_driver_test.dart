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
    final table = 'users_1';

    final query = Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);');
  });

  test('Create nullable field table Blueprint', () {
    final table = 'users_2';

    final query = Schema.create(table, (table) {
      table.increments('id');
      table.string('email').nullable();
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100), password VARCHAR(100) NOT NULL);');
  });

  test('Create unique field table Blueprint', () {
    final table = 'users_3';

    final query = Schema.create(table, (table) {
      table.increments('id');
      table.string('email').unique();
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) UNIQUE NOT NULL, password VARCHAR(100) NOT NULL);');
  });

  test('Create default value field table Blueprint', () {
    final table = 'users_4';

    final query = Schema.create(table, (table) {
      table.increments('id');
      table.string('email').unique().defaultsTo('john-doe@example.com');
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) UNIQUE NOT NULL DEFAULT \'john-doe@example.com\', password VARCHAR(100) NOT NULL);');
  });
}
