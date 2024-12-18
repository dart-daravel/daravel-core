import 'dart:io';

import 'package:daravel_core/globals.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/exceptions/db_connection_not_found.dart';

void main() {
  setUpAll(() {
    Directory(path.join(
            Directory.current.path, 'test/database-sqlite-driver-playground'))
        .createSync(recursive: true);

    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-sqlite-driver-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
        ),
        'sqlite1': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-sqlite-driver-playground/database1.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
          busyTimeout: 5000,
        ),
        'sqlite2': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-sqlite-driver-playground/database2.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
        ),
        's3': DatabaseConnection(
          driver: 's3',
          url: 'localhost',
          database: 'test',
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(
            Directory.current.path, 'test/database-sqlite-driver-playground'))
        .deleteSync(recursive: true);
    locator.reset();
  });

  test('Unsupported driver', () {
    expect(() => DB.connection('s3'), throwsA(isA<Exception>()));
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
      table.boolean('is_active').defaultsTo(true);
    });

    expect(query,
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) UNIQUE NOT NULL DEFAULT \'john-doe@example.com\', password VARCHAR(100) NOT NULL, is_active BOOLEAN NOT NULL DEFAULT 1);');
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

  test('Index field modifier', () {
    final table = 'users_7_1';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email').index();
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);\nCREATE INDEX email_index ON $table (email);');
  });

  test('Index field modifier with name', () {
    final table = 'users_7_2';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email').index('custom_index');
      table.string('password');
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);\nCREATE INDEX custom_index ON $table (email);');
  });

  test('Multiple indices via Blueprint class', () {
    final table = 'users_7_3';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email');
      table.string('password');
      table.string('phone');
      table.index(['email', 'password']);
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL, phone VARCHAR(100) NOT NULL);\nCREATE INDEX email_password_index ON $table (email, password);');
  });

  test('Indices via Blueprint class', () {
    final table = 'users_7_4';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email');
      table.string('password');
      table.string('phone');
      table.index('email');
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL, phone VARCHAR(100) NOT NULL);\nCREATE INDEX email_index ON $table (email);');
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

  test('Foreign key constraints with onDelete and onUpdate actions', () {
    final table1 = 'roles_1';
    final table2 = 'people_8';

    String query = Schema.create(table1, (table) {
      table.increments('id');
      table.string('name').unique();
    });

    expect(query,
        'CREATE TABLE $table1 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(100) UNIQUE NOT NULL);');

    query = Schema.create(table2, (table) {
      table.integer('id').primary().autoIncrement();
      table.string('name').unique();
      table.text('password');
      table.integer('role_id');
      table
          .foreign('role_id')
          .references('id')
          .on('roles')
          .onDelete('CASCADE')
          .onUpdate('CASCADE');
    });

    expect(query,
        'CREATE TABLE $table2 (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(100) UNIQUE NOT NULL, password TEXT NOT NULL, role_id INTEGER NOT NULL, CONSTRAINT ${table2}_role_id_foreign FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE);');
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

  test('Run SQL SELECT statement', () {
    final table = 'users_14';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    DB.connection()!.statement(query);
    // Select from connection.
    var result = DB.connection()!.select('SELECT * FROM $table');

    expect(result, isA<RecordSet>());

    expect(result!.length, 0);

    // Direct Select
    result = DB.select('SELECT * FROM $table');

    expect(result, isA<RecordSet>());

    expect(result!.length, 0);
  });

  test('Secondary Sqlite connection', () {
    final table = 'users_15';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    DB.connection('sqlite1')!.statement(query);

    // Select from connection.
    final result = DB.connection('sqlite1')!.select('SELECT * FROM $table');

    expect(result, isA<RecordSet>());

    expect(result!.length, 0);
  });

  test('Test non-existent connection & switching of default connection', () {
    final table = 'users_15';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    expect(() => DB.connection('sqlite-non-existent')!.statement(query),
        throwsA(isA<DBConnectionNotFoundException>()));

    expect(() => DB.setDefaultConnection('sqlite-non-existent'),
        throwsA(isA<DBConnectionNotFoundException>()));

    DB.setDefaultConnection('sqlite1');

    final result = DB.select('SELECT * FROM $table');

    expect(result, isA<RecordSet>());

    expect(result!.length, 0);
  });

  test('Insert statement', () {
    final table = 'users_16';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    DB.connection()!.unprepared(query);

    final result = DB.insert(
        'INSERT INTO $table (email, password) VALUES (?, ?)',
        ['john@gmail.com', 'password']);

    expect(result, true);

    final selectResult = DB.select('SELECT * FROM $table');

    expect(selectResult!.length, 1);

    expect(selectResult.first['id'], 1);
    expect(selectResult.first['email'], 'john@gmail.com');
    expect(selectResult.first['password'], 'password');

    expect(selectResult.first['id'], 1);
    expect(selectResult.first['email'], 'john@gmail.com');
    expect(selectResult.first['password'], 'password');
  });

  test('Delete statement', () async {
    final table = 'users_17';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    var selectResult = DB.select('SELECT * FROM $table');

    expect(selectResult!.length, 1);

    var result = await DB
        .delete('DELETE FROM $table WHERE email = ?', ['frank@gmail.com']);

    expect(result, 1);

    selectResult = DB.select('SELECT * FROM $table');

    expect(selectResult!.length, 0);
  });

  test('Update statement', () async {
    final table = 'users_18';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    var selectResult = DB.select('SELECT * FROM $table');

    expect(selectResult!.length, 1);

    var result = await DB.update(
      'UPDATE $table SET email = ?, password = ? WHERE email = ?',
      ['john-edited@gmail.com', 'new-password', 'john@gmail.com'],
    );

    expect(result, 1);

    selectResult = DB.select('SELECT * FROM $table');

    expect(selectResult!.length, 1);

    expect(selectResult.first['id'], 1);
    expect(selectResult.first['email'], 'john-edited@gmail.com');
    expect(selectResult.first['password'], 'new-password');

    expect(selectResult.first['id'], 1);
    expect(selectResult.first['email'], 'john-edited@gmail.com');
    expect(selectResult.first['password'], 'new-password');
  });

  test('Rename table', () {
    final table = 'users_19';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    DB.unprepared(query);

    final renameQuery = Schema.rename(table, 'new_users');

    expect(renameQuery, 'ALTER TABLE $table RENAME TO new_users;');

    final result = DB.select('SELECT * FROM new_users');

    expect(result!.length, 0);
  });

  test('Drop table', () {
    final table = 'users_20';
    final query =
        'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

    DB.statement(query);

    final dropQuery = Schema.drop(table);

    expect(dropQuery, 'DROP TABLE $table;');

    expect(() => DB.select('SELECT * FROM $table'),
        throwsA(isA<SqliteException>()));

    expect(Schema.dropIfExists(table), 'DROP TABLE IF EXISTS $table;');
  });

  test('Compound primary keys', () {
    final table = 'users_21';

    final query = Schema.create(table, (table) {
      table.string('id');
      table.string('email');
      table.string('password');
      table.primary(['id', 'email']);
    });

    expect(query,
        'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL, PRIMARY KEY (id, email));');
  });

  test('Update Schema', () {
    final table = 'users_22';

    final query = Schema.create(table, (table) {
      table.uuid();
      table.integer('employee_id').index();
      table.string('full_name');
      table.text('address');
      table.text('next_of_kin');
      table.string('next_of_kin_phone').index();

      table.index(['next_of_kin', 'next_of_kin_phone']);
    });

    expect(query,
        'CREATE TABLE $table (uuid CHAR(36) NOT NULL, employee_id INTEGER NOT NULL, full_name VARCHAR(100) NOT NULL, address TEXT NOT NULL, next_of_kin TEXT NOT NULL, next_of_kin_phone VARCHAR(100) NOT NULL);\nCREATE INDEX employee_id_index ON $table (employee_id);\nCREATE INDEX next_of_kin_phone_index ON users_22 (next_of_kin_phone);\nCREATE INDEX next_of_kin_next_of_kin_phone_index ON users_22 (next_of_kin, next_of_kin_phone);');

    final alterQuery = Schema.table(table, (table) {
      table.dropColumn('address');
      table.string('phone').index();
      table.renameColumn('full_name', 'first_name');
      table.dropIndex('employee_id_index');
    });

    expect(alterQuery,
        'ALTER TABLE $table ADD COLUMN phone VARCHAR(100);\nALTER TABLE $table DROP COLUMN address;\nALTER TABLE $table RENAME COLUMN full_name TO first_name;\nDROP INDEX employee_id_index;\nCREATE INDEX phone_index ON $table (phone);');
  });
}
