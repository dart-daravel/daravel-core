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

  test('Column comments not supported', () {
    final table = 'users_5';

    expect(
        () => Schema.create(table, (table) {
              table.increments('id').comment('This is the primary key');
            }),
        throwsA(isA<UnimplementedError>()));
  });

  test('Primary field modifier', () {
    final table = 'users_6';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email').primary();
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) PRIMARY KEY NOT NULL, password VARCHAR(100) NOT NULL);');
  });

  test('Signed and Unsigned integers not supported', () {
    final table = 'users_5';

    expect(
        () => Schema.create(table, (table) {
              table.integer('id').unsigned();
            }),
        throwsA(isA<UnimplementedError>()));
  });

  test('Foreign key constraints', () {
    final table1 = 'roles';
    final table2 = 'users_7';

    String query = Schema.create(table1, (table) {
      table.increments('id');
      table.string('name').unique();
    });

    expect(query,
        'CREATE TABLE $table1 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(100) UNIQUE NOT NULL);');

    query = Schema.create(table2, (table) {
      table.increments('id');
      table.string('name').unique();
      table.string('password');
      table.integer('role_id');
      table.foreign('role_id').references('id').on('roles');
    });

    expect(query,
        'CREATE TABLE $table2 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(100) UNIQUE NOT NULL, password VARCHAR(100) NOT NULL, role_id INTEGER NOT NULL, CONSTRAINT ${table2}_role_id_foreign FOREIGN KEY (role_id) REFERENCES roles(id));');
  });

  test('Uuid column type', () {
    final table = 'users_8';

    final query = Schema.create(table, (table) {
      table.uuid();
    });

    expect(query, 'CREATE TABLE $table (uuid CHAR(36) NOT NULL);');
  });

  test('Char column type', () {
    final table = 'users_9';

    final query = Schema.create(table, (table) {
      table.char('name');
    });

    expect(query, 'CREATE TABLE $table (name CHAR(50) NOT NULL);');
  });

  test('Date column type', () {
    final table = 'users_10';

    final query = Schema.create(table, (table) {
      table.date('dob');
    });

    expect(query, 'CREATE TABLE $table (dob DATE NOT NULL);');
  });

  test('DateTime column type', () {
    final table = 'users_11';

    expect(
        () => Schema.create(table, (table) {
              table.dateTime('created_at');
            }),
        throwsA(isA<UnimplementedError>()));
  });

  test('Time column type', () {
    final table = 'users_12';

    expect(
        () => Schema.create(table, (table) {
              table.time('time');
            }),
        throwsA(isA<UnimplementedError>()));
  });

  test('Timestamp column type', () {
    final table = 'users_13';

    expect(
        () => Schema.create(table, (table) {
              table.timestamp('created_at');
            }),
        throwsA(isA<UnimplementedError>()));
  });
}
