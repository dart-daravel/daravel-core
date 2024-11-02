import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record_set.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/exceptions/query.dart';
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
          queryLog: true,
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(Directory.current.path,
            'test/database-sqlite-query-builder-playground'))
        .deleteSync(recursive: true);
  });

  test('Select all rows', () {
    final table = 'users_1';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
    });

    DB.insert(
      'INSERT INTO $table (email, password, name) VALUES (?, ?, ?)',
      ['frank@gmail.com', 'password', 'Frank'],
    );

    final result = DB.table(table).get();

    expect(result.length, 1);
    expect(result.first['email'], 'frank@gmail.com');
    expect(result.first['password'], 'password');

    final result2 = DB.table(table).select(['email', 'password']).get();

    expect(result2.length, 1);
    expect(result2.first['email'], 'frank@gmail.com');
    expect(result2.first['password'], 'password');
  });

  test('Where clause', () {
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
    expect(result.first['email'], 'frank@gmail.com');
  });

  test('OrWhere clause', () {
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
    expect(result.first['email'], 'frank@gmail.com');
  });

  test('first()', () {
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

  test('firstOrFail()', () {
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

  test('value([column])', () {
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

  test('find([id])', () {
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

  test('pluck([column])', () {
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

  test('chunk([size]) with orderBy', () {
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
        expect(records[0]['email'], allRecords[0]['email']);
        expect(records[1]['email'], allRecords[1]['email']);
      } else if (chunkCount == 2) {
        expect(records.length, 2);
        expect(records[0]['email'], allRecords[2]['email']);
        expect(records[1]['email'], allRecords[3]['email']);
      } else if (chunkCount == 3) {
        expect(records.length, 1);
        expect(records[0]['email'], allRecords[4]['email']);
      }
      chunkCount++;
      return null;
    });

    // Illegal State
    expect(
        () =>
            DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
              query
                  .where('address', 'Pluto')
                  .orWhere('address', 'Earth')
                  .chunk(2, (records) => null);
            }).get(),
        throwsA(isA<QueryException>()));
  });

  test('chunkById([size]) with orderBy', () {
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
        expect(records[0]['email'], allRecords[0]['email']);
        expect(records[1]['email'], allRecords[1]['email']);
      } else if (chunkCount == 2) {
        expect(records.length, 2);
        expect(records[0]['email'], allRecords[2]['email']);
        expect(records[1]['email'], allRecords[3]['email']);
      } else if (chunkCount == 3) {
        expect(records.length, 1);
        expect(records[0]['email'], allRecords[4]['email']);
      }
      chunkCount++;
      return null;
    });

    // Illegal State
    expect(
        () =>
            DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
              query
                  .where('address', 'Pluto')
                  .orWhere('address', 'Earth')
                  .chunkById(2, (records) => null);
            }).get(),
        throwsA(isA<QueryException>()));
  });

  test('insert()', () async {
    final table = 'users_11';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    int? insertId;

    insertId = await DB
        .table(table)
        .insert({'email': 'tok@gmail.com', 'password': 'password'});

    expect(1, insertId);

    insertId = await DB
        .table(table)
        .insert({'email': 'tak@gmail.com', 'password': 'password'});

    expect(2, insertId);

    // Error case
    expect(() => DB.table(table).insert({}), throwsA(isA<QueryException>()));
  });

  test('update()', () async {
    final table = 'users_12';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
    });

    int? affectedRows;

    await DB
        .table(table)
        .insert({'email': 'tok@gmail.com', 'password': 'password'});

    await DB
        .table(table)
        .insert({'email': 'tak@gmail.com', 'password': 'password'});

    affectedRows = await DB
        .table(table)
        .where('email', 'tok@gmail.com')
        .update({'password': 'edited'});

    expect(affectedRows, 1);

    final result = DB.table(table).where('email', 'tok@gmail.com').first();

    expect(result?['password'], 'edited');

    affectedRows = await DB.table(table).update({'password': 'edited-again'});

    final allRecords = DB.table(table).get();

    expect(allRecords[0]['password'], 'edited-again');
    expect(allRecords[1]['password'], 'edited-again');

    expect(affectedRows, 2);

    // Error case
    expect(() => DB.table(table).update({}), throwsA(isA<QueryException>()));
  });

  test('Bracket grouped where clause', () async {
    final table = 'users_13';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    await DB.table(table).insert({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    await DB.table(table).insert({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    final result =
        DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
      query.where('address', 'Pluto').orWhere('address', 'Earth');
    }).get();

    expect(result.length, 2);

    expect(result[0]['email'], 'tok@gmail.com');
    expect(result[1]['email'], 'jack@gmail.com');

    final result2 =
        DB.table(table).where('age', '<=', 5).orWhere((QueryBuilder query) {
      query.where('address', 'Pluto').where('name', 'Jack');
    }).get();

    expect(result2.length, 1);

    // Illegal State
    expect(
        () =>
            DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
              query.where('address', 'Pluto').orWhere('address', 'Earth').get();
            }).get(),
        throwsA(isA<QueryException>()));
  });

  test('lazy.each()', () async {
    final table = 'users_14';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 2
    });

    await DB.table(table).insert({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 0
    });

    int rowCount = 0;

    await DB.table(table).orderBy('age', 'ASC').lazy().each((record) {
      expect(record, isA<SqliteRecord>());
      expect(record['age'], rowCount);
      rowCount++;
      return null;
    });

    expect(rowCount, 3);

    // Illegal State
    expect(
        () =>
            DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
              query
                  .where('address', 'Pluto')
                  .orWhere('address', 'Earth')
                  .lazy();
            }).get(),
        throwsA(isA<QueryException>()));
  });

  test('lazyById.each()', () async {
    final table = 'users_15';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    await DB.table(table).insert({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    await DB.table(table).insert({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    int rowCount = 0;

    await DB.table(table).lazyById().each((record) {
      expect(record, isA<SqliteRecord>());
      expect(record['id'], rowCount + 1);
      rowCount++;
      return null;
    });

    expect(rowCount, 3);

    // Illegal State
    expect(
        () =>
            DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
              query
                  .where('address', 'Pluto')
                  .orWhere('address', 'Earth')
                  .lazyById();
            }).get(),
        throwsA(isA<QueryException>()));
  });

  test('Aggregates', () async {
    final table = 'users_16';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email').unique();
      table.string('password');
      table.string('name').nullable();
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 2
    });

    await DB.table(table).insert({
      'email': 'take@gmail.com',
      'password': 'password',
      'address': 'Earth',
      'age': 3
    });

    await DB.table(table).insert({
      'email': 'tk@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 4
    });

    // AVG.
    expect(DB.table(table).avg('age'), 2.5);
    expect(DB.table(table).where('age', '>', 10).avg('age'), 0); // Null case.

    // Count
    expect(DB.table(table).count(), 4);
    expect(DB.table(table).where('age', '>', 10).count(), 0);
    expect(DB.table(table).count('name'), 3);

    // Max
    expect(DB.table(table).max('age'), 4);
    expect(DB.table(table).where('age', '>', 10).max('age'), 0);

    // Min
    expect(DB.table(table).min('age'), 1);
    expect(DB.table(table).where('age', '>', 10).min('age'), 0);

    // Sum
    expect(DB.table(table).sum('age'), 10);
    expect(DB.table(table).where('age', '>', 10).sum('age'), 0);
  });

  test('exists & doesntExist', () async {
    final table = 'users_17';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email').unique();
      table.string('password');
      table.string('name').nullable();
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 2
    });

    await DB.table(table).insert({
      'email': 'take@gmail.com',
      'password': 'password',
      'address': 'Earth',
      'age': 3
    });

    await DB.table(table).insert({
      'email': 'tk@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 4
    });

    // Exists.
    expect(DB.table(table).where('address', 'Earth').exists(), true);
    expect(DB.table(table).where('address', 'Venus').exists(), false);

    // Doesn't Exists
    expect(DB.table(table).where('address', 'Earth').doesntExist(), false);
    expect(DB.table(table).where('address', 'Venus').doesntExist(), true);
  });

  test('delete()', () async {
    final table = 'users_18';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email').unique();
      table.string('password');
      table.string('name').nullable();
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 2
    });

    await DB.table(table).insert({
      'email': 'take@gmail.com',
      'password': 'password',
      'address': 'Earth',
      'age': 3
    });

    await DB.table(table).insert({
      'email': 'tk@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 4
    });

    expect(DB.table(table).count(), 4);

    int deletedRows =
        await DB.table(table).where('email', 'tok@gmail.com').delete();

    expect(deletedRows, 1);
    expect(DB.table(table).count(), 3);

    deletedRows = await DB.table(table).delete();

    expect(deletedRows, 3);
    expect(DB.table(table).count(), 0);
  });

  test('distinct()', () async {
    final table = 'users_19';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    await DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'address': 'Earth',
      'name': 'Jon',
      'age': 1
    });

    await DB.table(table).insert({
      'email': 'ta@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 1
    });

    expect(DB.table(table).count(), 4);
    final query = DB.table(table).select('email').distinct();
    query.addSelect('password');
    expect(query.distinct().get().length, 2);

    expect(DB.table(table).distinct().count('email'), 2);
  });
}
