import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/exceptions/record_not_found.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  setUpAll(() {
    Directory(path.join(Directory.current.path,
            'test/database-sqlite-query-builder-playground'))
        .createSync(recursive: true);

    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database:
              'test/database-sqlite-query-builder-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(Directory.current.path,
            'test/database-sqlite-query-builder-playground'))
        .deleteSync(recursive: true);
  });

  test('Select all rows', () async {
    final table = 'users_1';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    final result = DB.table(table).get();

    expect(result.length, 1);
    expect(result.first?['email'], 'frank@gmail.com');
    expect(result.first?['password'], 'password');
  });

  test('Where clause', () async {
    final table = 'users_2';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result = DB.table(table).where('email', 'frank@gmail.com').get();

    expect(result.length, 1);
    expect(result.first?['email'], 'frank@gmail.com');
  });

  test('OrWhere clause', () async {
    final table = 'users_3';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result = DB
        .table(table)
        .where('email', 'frank@gmail.com')
        .orWhere('email', 'john@gmail.com')
        .get();

    expect(result.length, 2);
    expect(result.first?['email'], 'frank@gmail.com');
  });

  test('first()', () async {
    final table = 'users_4';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result1 = DB
        .table(table)
        .where('email', 'frank@gmail.com')
        .orWhere('email', 'john@gmail.com')
        .first();

    expect(result1?['email'], 'frank@gmail.com');

    final result2 = DB
        .table(table)
        .where('email', 'frank-no@gmail.com')
        .orWhere('email', 'john-no@gmail.com')
        .first();

    expect(result2, null);
  });

  test('firstOrFail()', () async {
    final table = 'users_5';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    expect(
        () =>
            DB.table(table).where('email', 'doe-john@gmail.com').firstOrFail(),
        throwsA(isA<RecordNotFoundException>()));
  });

  test('value([column])', () async {
    final table = 'users_6';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result =
        DB.table(table).where('email', 'frank@gmail.com').value('email');

    expect(result, 'frank@gmail.com');
  });

  test('find([id])', () async {
    final table = 'users_7';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result = DB.table(table).find(1);

    expect(result?['email'], 'frank@gmail.com');
  });

  test('pluck([column])', () async {
    final table = 'users_8';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    final result1 = DB.table(table).pluck('email');

    expect(result1, ['frank@gmail.com', 'john@gmail.com']);

    final result2 =
        DB.table(table).where('email', 'frank@gmail.com').pluck('email');

    expect(result2, ['frank@gmail.com']);
  });

  test('chunk([size]) with orderBy', () async {
    final table = 'users_9';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['a@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['b@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['c@gmail.com', 'password'],
    );

    int chunkCount = 1;

    final allRecords = DB.table(table).orderBy('email', 'DESC').get();

    DB.table(table).orderBy('email', 'DESC').chunk(2, (records) {
      if (chunkCount == 1) {
        expect(records.length, 2);
        expect(records[0]?['email'], allRecords[0]?['email']);
        expect(records[1]?['email'], allRecords[1]?['email']);
      } else if (chunkCount == 2) {
        expect(records.length, 2);
        expect(records[0]?['email'], allRecords[2]?['email']);
        expect(records[1]?['email'], allRecords[3]?['email']);
      } else if (chunkCount == 3) {
        expect(records.length, 1);
        expect(records[0]?['email'], allRecords[4]?['email']);
      }
      chunkCount++;
      return null;
    });
  });

  test('chunkById([size]) with orderBy', () async {
    final table = 'users_10';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['frank@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['john@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['a@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['b@gmail.com', 'password'],
    );

    DB.insert(
      'INSERT INTO $table (email, password) VALUES (?, ?)',
      ['c@gmail.com', 'password'],
    );

    int chunkCount = 1;

    final allRecords = DB.table(table).orderBy('id', 'DESC').get();

    DB.table(table).orderBy('id', 'DESC').chunkById(2, (records) {
      if (chunkCount == 1) {
        expect(records.length, 2);
        expect(records[0]?['email'], allRecords[0]?['email']);
        expect(records[1]?['email'], allRecords[1]?['email']);
      } else if (chunkCount == 2) {
        expect(records.length, 2);
        expect(records[0]?['email'], allRecords[2]?['email']);
        expect(records[1]?['email'], allRecords[3]?['email']);
      } else if (chunkCount == 3) {
        expect(records.length, 1);
        expect(records[0]?['email'], allRecords[4]?['email']);
      }
      chunkCount++;
      return null;
    });
  });
}
