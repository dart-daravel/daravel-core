import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';

import 'package:daravel_core/globals.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  setUpAll(() {
    Directory(path.join(Directory.current.path,
            'test/database-mongodb-query-builder-playground'))
        .createSync(recursive: true);

    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'mongodb',
      'database.connections': {
        'mongodb': DatabaseConnection(
          driver: 'mongodb',
          database: 'daravel',
          dsn: 'mongodb://localhost:27017',
          queryLog: true,
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(Directory.current.path,
            'test/database-mongodb-query-builder-playground'))
        .deleteSync(recursive: true);
    locator.reset();
  });

  // test('Select all rows', () async {
  //   final table = 'users_1';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password, name) VALUES (?, ?, ?)',
  //     ['frank@gmail.com', 'password', 'Frank'],
  //   );

  //   final result = await DB.table(table).get();

  //   expect(result.length, 1);
  //   expect(result.first['email'], 'frank@gmail.com');
  //   expect(result.first['password'], 'password');

  //   final result2 = await DB.table(table).select(['email', 'password']).get();

  //   expect(result2.length, 1);
  //   expect(result2.first['email'], 'frank@gmail.com');
  //   expect(result2.first['password'], 'password');
  // });

  // test('Where clause', () async {
  //   final table = 'users_2';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result =
  //       await DB.table(table).where('email', 'frank@gmail.com').get();

  //   expect(result.length, 1);
  //   expect(result.first['email'], 'frank@gmail.com');
  // });

  // test('OrWhere clause', () async {
  //   final table = 'users_3';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result = await DB
  //       .table(table)
  //       .where('email', 'frank@gmail.com')
  //       .orWhere('email', 'john@gmail.com')
  //       .get();

  //   expect(result.length, 2);
  //   expect(result.first['email'], 'frank@gmail.com');
  // });

  // test('first()', () async {
  //   final table = 'users_4';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result1 = await DB
  //       .table(table)
  //       .where('email', 'frank@gmail.com')
  //       .orWhere('email', 'john@gmail.com')
  //       .first();

  //   expect(result1!['email'], 'frank@gmail.com');

  //   final result2 = await DB
  //       .table(table)
  //       .where('email', 'frank-no@gmail.com')
  //       .orWhere('email', 'john-no@gmail.com')
  //       .first();

  //   expect(result2, null);
  // });

  // test('firstOrFail()', () {
  //   final table = 'users_5';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   expect(
  //       () =>
  //           DB.table(table).where('email', 'doe-john@gmail.com').firstOrFail(),
  //       throwsA(isA<RecordNotFoundException>()));
  // });

  // test('value([column])', () async {
  //   final table = 'users_6';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result =
  //       await DB.table(table).where('email', 'frank@gmail.com').value('email');

  //   expect(result, 'frank@gmail.com');
  // });

  // test('find([id])', () async {
  //   final table = 'users_7';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result = await DB.table(table).find(1);

  //   expect(result?['email'], 'frank@gmail.com');
  // });

  // test('pluck([column])', () async {
  //   final table = 'users_8';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   final result1 = await DB.table(table).pluck('email');

  //   expect(result1, ['frank@gmail.com', 'john@gmail.com']);

  //   final result2 =
  //       await DB.table(table).where('email', 'frank@gmail.com').pluck('email');

  //   expect(result2, ['frank@gmail.com']);
  // });

  // test('chunk([size]) with orderBy', () async {
  //   final table = 'users_9';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['a@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['b@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['c@gmail.com', 'password'],
  //   );

  //   int chunkCount = 1;

  //   final allRecords = await DB.table(table).orderBy('email', 'DESC').get();

  //   DB.table(table).orderBy('email', 'DESC').chunk(2, (records) {
  //     if (chunkCount == 1) {
  //       expect(records.length, 2);
  //       expect(records[0]['email'], allRecords[0]['email']);
  //       expect(records[1]['email'], allRecords[1]['email']);
  //     } else if (chunkCount == 2) {
  //       expect(records.length, 2);
  //       expect(records[0]['email'], allRecords[2]['email']);
  //       expect(records[1]['email'], allRecords[3]['email']);
  //     } else if (chunkCount == 3) {
  //       expect(records.length, 1);
  //       expect(records[0]['email'], allRecords[4]['email']);
  //     }
  //     chunkCount++;
  //     return null;
  //   });

  //   // Illegal State
  //   expect(
  //       () async => (await DB
  //               .table(table)
  //               .where('age', '<=', 20)
  //               .whereAsync((QueryBuilder query) async {
  //             await query
  //                 .where('address', 'Pluto')
  //                 .orWhere('address', 'Earth')
  //                 .chunk(2, (records) => null);
  //           })),
  //       throwsA(isA<QueryException>()));
  // });

  // test('chunkById([size]) with orderBy', () async {
  //   final table = 'users_10';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['frank@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['a@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['b@gmail.com', 'password'],
  //   );

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['c@gmail.com', 'password'],
  //   );

  //   int chunkCount = 1;

  //   final allRecords = await DB.table(table).orderBy('id', 'DESC').get();

  //   DB.table(table).orderBy('id', 'DESC').chunkById(2, (records) {
  //     if (chunkCount == 1) {
  //       expect(records.length, 2);
  //       expect(records[0]['email'], allRecords[0]['email']);
  //       expect(records[1]['email'], allRecords[1]['email']);
  //     } else if (chunkCount == 2) {
  //       expect(records.length, 2);
  //       expect(records[0]['email'], allRecords[2]['email']);
  //       expect(records[1]['email'], allRecords[3]['email']);
  //     } else if (chunkCount == 3) {
  //       expect(records.length, 1);
  //       expect(records[0]['email'], allRecords[4]['email']);
  //     }
  //     chunkCount++;
  //     return null;
  //   });

  //   // Illegal State
  //   expect(
  //       () async => (await DB
  //                   .table(table)
  //                   .where('age', '<=', 20)
  //                   .whereAsync((QueryBuilder query) async {
  //             await query
  //                 .where('address', 'Pluto')
  //                 .orWhere('address', 'Earth')
  //                 .chunkById(2, (records) => null);
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));
  // });

  // test('insert()', () async {
  //   final table = 'users_11';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   int? insertId;

  //   insertId = await DB
  //       .table(table)
  //       .insertGetId({'email': 'tok@gmail.com', 'password': 'password'});

  //   expect(1, insertId);

  //   insertId = await DB
  //       .table(table)
  //       .insertGetId({'email': 'tak@gmail.com', 'password': 'password'});

  //   expect(2, insertId);

  //   // Error case
  //   expect(() => DB.table(table).insert({}), throwsA(isA<QueryException>()));
  //   expect(
  //       () => DB.table(table).insertGetId({}), throwsA(isA<QueryException>()));
  // });

  // test('update()', () async {
  //   final table = 'users_12';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   int? affectedRows;

  //   DB.table(table).insert({'email': 'tok@gmail.com', 'password': 'password'});

  //   DB.table(table).insert({'email': 'tak@gmail.com', 'password': 'password'});

  //   affectedRows = await DB
  //       .table(table)
  //       .where('email', 'tok@gmail.com')
  //       .update({'password': 'edited'});

  //   expect(affectedRows, 1);

  //   final result =
  //       await DB.table(table).where('email', 'tok@gmail.com').first();

  //   expect(result?['password'], 'edited');

  //   affectedRows = await DB.table(table).update({'password': 'edited-again'});

  //   final allRecords = await DB.table(table).get();

  //   expect(allRecords[0]['password'], 'edited-again');
  //   expect(allRecords[1]['password'], 'edited-again');

  //   expect(affectedRows, 2);

  //   // Error case
  //   expect(() => DB.table(table).update({}), throwsA(isA<QueryException>()));
  // });

  // test('Bracket grouped where clause', () async {
  //   final table = 'users_13';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 20
  //   });

  //   DB.table(table).insert({
  //     'email': 'tak@gmail.com',
  //     'password': 'password',
  //     'name': 'Tak',
  //     'address': 'Mars',
  //     'age': 25
  //   });

  //   DB.table(table).insert({
  //     'email': 'jack@gmail.com',
  //     'password': 'password',
  //     'name': 'Jack',
  //     'address': 'Pluto',
  //     'age': 19
  //   });

  //   final result = await DB
  //       .table(table)
  //       .where('age', '<=', 20)
  //       .where((QueryBuilder query) {
  //     query.where('address', 'Pluto').orWhere('address', 'Earth');
  //   }).get();

  //   expect(result.length, 2);

  //   expect(result[0]['email'], 'tok@gmail.com');
  //   expect(result[1]['email'], 'jack@gmail.com');

  //   final result2 = await DB
  //       .table(table)
  //       .where('age', '<=', 5)
  //       .orWhere((QueryBuilder query) {
  //     query.where('address', 'Pluto').where('name', 'Jack');
  //   }).get();

  //   expect(result2.length, 1);

  //   // Illegal State
  //   expect(
  //       () async => (await DB.table(table).where('age', '<=', 20).whereAsync(
  //             (QueryBuilder query) async {
  //               await query
  //                   .where('address', 'Pluto')
  //                   .orWhere('address', 'Earth')
  //                   .get();
  //             },
  //           ))
  //               .get(),
  //       throwsA(isA<QueryException>()));
  // });

  // test('lazy.each()', () async {
  //   final table = 'users_14';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'tak@gmail.com',
  //     'password': 'password',
  //     'name': 'Tak',
  //     'address': 'Mars',
  //     'age': 2
  //   });

  //   DB.table(table).insert({
  //     'email': 'jack@gmail.com',
  //     'password': 'password',
  //     'name': 'Jack',
  //     'address': 'Pluto',
  //     'age': 0
  //   });

  //   int rowCount = 0;

  //   await DB.table(table).orderBy('age', 'ASC').lazy().each((record) {
  //     expect(record, isA<SqliteRecord>());
  //     expect(record['age'], rowCount);
  //     rowCount++;
  //     return null;
  //   });

  //   expect(rowCount, 3);

  //   // Illegal State
  //   expect(
  //       () =>
  //           DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
  //             query
  //                 .where('address', 'Pluto')
  //                 .orWhere('address', 'Earth')
  //                 .lazy();
  //           }).get(),
  //       throwsA(isA<QueryException>()));
  // });

  // test('lazyById.each()', () async {
  //   final table = 'users_15';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 20
  //   });

  //   DB.table(table).insert({
  //     'email': 'tak@gmail.com',
  //     'password': 'password',
  //     'name': 'Tak',
  //     'address': 'Mars',
  //     'age': 25
  //   });

  //   DB.table(table).insert({
  //     'email': 'jack@gmail.com',
  //     'password': 'password',
  //     'name': 'Jack',
  //     'address': 'Pluto',
  //     'age': 19
  //   });

  //   int rowCount = 0;

  //   await DB.table(table).lazyById().each((record) {
  //     expect(record, isA<SqliteRecord>());
  //     expect(record['id'], rowCount + 1);
  //     rowCount++;
  //     return null;
  //   });

  //   expect(rowCount, 3);

  //   // Illegal State
  //   expect(
  //       () =>
  //           DB.table(table).where('age', '<=', 20).where((QueryBuilder query) {
  //             query
  //                 .where('address', 'Pluto')
  //                 .orWhere('address', 'Earth')
  //                 .lazyById();
  //           }).get(),
  //       throwsA(isA<QueryException>()));
  // });

  // test('Aggregates', () async {
  //   final table = 'users_16';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email').unique();
  //     table.string('password');
  //     table.string('name').nullable();
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 2
  //   });

  //   DB.table(table).insert({
  //     'email': 'take@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'age': 3
  //   });

  //   DB.table(table).insert({
  //     'email': 'tk@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 4
  //   });

  //   // AVG.
  //   expect(await DB.table(table).avg('age'), 2.5);
  //   expect(await DB.table(table).where('age', '>', 10).avg('age'),
  //       0); // Null case.

  //   // Illegal State
  //   expect(
  //       () async => (await DB
  //                   .table(table)
  //                   .where('age', '<=', 4)
  //                   .whereAsync((QueryBuilder query) async {
  //             await query.avg('age');
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));

  //   // Count
  //   expect(await DB.table(table).count(), 4);
  //   expect(await DB.table(table).where('age', '>', 10).count(), 0);
  //   expect(await DB.table(table).count('name'), 3);

  //   // Illegal State
  //   expect(
  //       () async => (await DB
  //                   .table(table)
  //                   .where('age', '<=', 4)
  //                   .whereAsync((QueryBuilder query) async {
  //             await query.count();
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));
  //   // Distinct with multiple columns.
  //   expect(
  //       () => DB
  //           .table(table)
  //           .where('age', '<=', 4)
  //           .distinct()
  //           .count('name, address'),
  //       throwsA(isA<QueryException>()));

  //   // Max
  //   expect(await DB.table(table).max('age'), 4);
  //   expect(await DB.table(table).where('age', '>', 10).max('age'), 0);

  //   // Illegal State
  //   expect(
  //       () async =>
  //           (await DB.table(table).whereAsync((QueryBuilder query) async {
  //             await query.max('age');
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));

  //   // Min
  //   expect(await DB.table(table).min('age'), 1);
  //   expect(await DB.table(table).where('age', '>', 10).min('age'), 0);

  //   // Illegal State
  //   expect(
  //       () async =>
  //           (await DB.table(table).whereAsync((QueryBuilder query) async {
  //             await query.min('age');
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));

  //   // Sum
  //   expect(await DB.table(table).sum('age'), 10);
  //   expect(await DB.table(table).where('age', '>', 10).sum('age'), 0);

  //   // Illegal State
  //   expect(
  //       () async =>
  //           (await DB.table(table).whereAsync((QueryBuilder query) async {
  //             await query.sum('age');
  //           }))
  //               .get(),
  //       throwsA(isA<QueryException>()));
  // });

  // test('exists & doesntExist', () async {
  //   final table = 'users_17';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email').unique();
  //     table.string('password');
  //     table.string('name').nullable();
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 2
  //   });

  //   DB.table(table).insert({
  //     'email': 'take@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'age': 3
  //   });

  //   DB.table(table).insert({
  //     'email': 'tk@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 4
  //   });

  //   // Exists.
  //   expect(await DB.table(table).where('address', 'Earth').exists(), true);
  //   expect(await DB.table(table).where('address', 'Venus').exists(), false);

  //   // Doesn't Exists
  //   expect(
  //       await DB.table(table).where('address', 'Earth').doesntExist(), false);
  //   expect(await DB.table(table).where('address', 'Venus').doesntExist(), true);
  // });

  // test('delete()', () async {
  //   final table = 'users_18';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email').unique();
  //     table.string('password');
  //     table.string('name').nullable();
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 2
  //   });

  //   DB.table(table).insert({
  //     'email': 'take@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'age': 3
  //   });

  //   DB.table(table).insert({
  //     'email': 'tk@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 4
  //   });

  //   DB.table(table).insert({
  //     'email': 'tko@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 11
  //   });

  //   expect(await DB.table(table).count(), 5);

  //   int deletedRows =
  //       await DB.table(table).where('email', 'tok@gmail.com').delete();

  //   expect(deletedRows, 1);
  //   expect(await DB.table(table).count(), 4);

  //   deletedRows = await DB.table(table).where('age', '>', 10).delete();

  //   expect(deletedRows, 1);
  //   expect(await DB.table(table).count(), 3);

  //   deletedRows = await DB.table(table).delete(4);

  //   expect(deletedRows, 1);
  //   expect(await DB.table(table).count(), 2);

  //   deletedRows = await DB.table(table).delete();

  //   expect(deletedRows, 2);
  //   expect(await DB.table(table).count(), 0);
  // });

  // test('distinct()', () async {
  //   final table = 'users_19';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   expect(await DB.table(table).count(), 4);
  //   final query = DB.table(table).select('email').distinct();
  //   query.addSelect('password');
  //   expect((await query.distinct().get()).length, 2);

  //   expect(await DB.table(table).distinct().count('email'), 2);
  // });

  // test('selectRaw()', () async {
  //   final table = 'users_20';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 3
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 6
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //     'age': 19
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 100
  //   });

  //   final result1 = await DB.table(table).select('email, password').get();

  //   expect(result1.first['password'], null);

  //   final result2 = await DB.table(table).selectRaw('email, password').get();

  //   expect(result2.first['password'], 'password');
  //   expect(result2.first['address'], null);

  //   // With Bindings
  //   final result3 =
  //       await DB.table(table).selectRaw('age * ? as double_age', [2]).get();

  //   expect(result3[0]['double_age'], 6);
  //   expect(result3[1]['double_age'], 12);
  //   expect(result3[2]['double_age'], 38);
  //   expect(result3[3]['double_age'], 200);

  //   // Multiple columns with bindings
  //   final result4 = await DB
  //       .table(table)
  //       .select('name')
  //       .selectRaw('age * ? as double_age', [2]).get();

  //   expect(result4[0]['double_age'], 6);
  //   expect(result4[1]['double_age'], 12);
  //   expect(result4[2]['double_age'], 38);
  //   expect(result4[3]['double_age'], 200);

  //   // Using DB.raw()
  //   final result5 = await DB
  //       .table(table)
  //       .select(DB.raw('age * ? as double_age', [2]))
  //       .get();

  //   expect(result5[0]['double_age'], 6);
  //   expect(result5[1]['double_age'], 12);
  //   expect(result5[2]['double_age'], 38);
  //   expect(result5[3]['double_age'], 200);
  // });

  // test('whereRaw()', () async {
  //   final table = 'users_21';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age').defaultsTo(1);
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta2@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta1@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   final result =
  //       await DB.table(table).whereRaw("email = 'ta@gmail.com'").get();

  //   expect(result.length, 1);
  //   expect(result.first['email'], 'ta@gmail.com');
  // });

  // test('orWhereRaw()', () async {
  //   final table = 'users_21_or_where_raw';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age').defaultsTo(1);
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta2@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta1@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //   });

  //   final result = await DB
  //       .table(table)
  //       .whereRaw("email = 'ta@gmail.com'")
  //       .orWhereRaw("email = 'ta1@gmail.com'")
  //       .get();

  //   expect(result.length, 2);
  //   expect(result.first['email'], 'ta1@gmail.com');
  //   expect(result[1]['email'], 'ta@gmail.com');
  // });

  // test('groupBy()', () async {
  //   final table = 'users_22';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   final result = await DB.table(table).where('age', 1).groupBy('email').get();

  //   expect(result.length, 2);
  // });

  // test('addSelect()', () async {
  //   final table = 'users_23';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //     table.string('name');
  //     table.string('address');
  //     table.integer('age');
  //   });

  //   DB.table(table).insert({
  //     'email': 'tok@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'address': 'Earth',
  //     'name': 'Jon',
  //     'age': 1
  //   });

  //   DB.table(table).insert({
  //     'email': 'ta@gmail.com',
  //     'password': 'password',
  //     'name': 'Jon',
  //     'address': 'Earth',
  //     'age': 1
  //   });

  //   final query = DB.table(table).select(['email', 'password']);

  //   final result1 = await query.get();

  //   expect(result1.length, 4);

  //   expect(result1.first['email'], 'tok@gmail.com');
  //   expect(result1.first['password'], 'password');
  //   expect(result1.first['name'], null);

  //   query.addSelect('name');

  //   final result2 = await query.get();

  //   expect(result2.length, 4);

  //   expect(result2.first['email'], 'tok@gmail.com');
  //   expect(result2.first['password'], 'password');
  //   expect(result2.first['name'], 'Jon');
  // });
}
