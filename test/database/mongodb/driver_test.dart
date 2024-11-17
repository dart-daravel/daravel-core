import 'package:daravel_core/globals.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';

void main() {
  setUpAll(() {
    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'mongodb',
      'database.connections': {
        'mongodb': DatabaseConnection(
          driver: 'mongodb',
          database: 'daravel',
          dsn: 'mongodb://localhost:27017',
          prefix: '',
          foreignKeyConstraints: true,
          queryLog: true,
        ),
      }
    }));
  });

  tearDownAll(() async {
    await (DB.connection()!.driver.nativeConnectionInstance as Db).drop();
    locator.reset();
  });

  test('insertOne(), find() or select()', () async {
    final collection = 'users_1';

    final result = await DB.connection()!.insert(
          collection,
          NoSqlQuery(
            type: QueryType.insert,
            insertValues: {
              'name': 'A',
              'email': 'a@gmail.com',
              'address': 'Earth',
            },
          ),
        ) as Map<String, dynamic>;

    final user = await DB.connection()!.findOne(
        collection,
        NoSqlQuery(whereMap: {
          'name': 'A',
        }));

    expect(user!['email'], 'a@gmail.com');
    expect(user['_id'], result['_id']);
  });

  test('Delete statement', () async {
    final collection = 'users_2';

    final result = await DB.connection()!.insert(
          collection,
          NoSqlQuery(
            type: QueryType.insert,
            insertValues: {
              'name': 'A',
              'email': 'a@gmail.com',
              'address': 'Earth',
            },
          ),
        ) as Map<String, dynamic>;

    final user = await DB.connection()!.findOne(
        collection,
        NoSqlQuery(whereMap: {
          'name': 'A',
        }));

    expect(user!['email'], 'a@gmail.com');
    expect(user['_id'], result['_id']);

    // await DB.connection()!.delete(collection,
    //     NoSqlQuery(type: QueryType.delete, whereMap: {'_id': user['_id']}));
  });

  // test('Update statement', () async {
  //   final table = 'users_18';

  //   Schema.create(table, (table) {
  //     table.increments('id');
  //     table.string('email');
  //     table.string('password');
  //   });

  //   DB.insert(
  //     'INSERT INTO $table (email, password) VALUES (?, ?)',
  //     ['john@gmail.com', 'password'],
  //   );

  //   var selectResult = await DB.select('SELECT * FROM $table');

  //   expect(selectResult.length, 1);

  //   var result = await DB.update(
  //     'UPDATE $table SET email = ?, password = ? WHERE email = ?',
  //     ['john-edited@gmail.com', 'new-password', 'john@gmail.com'],
  //   );

  //   expect(result, 1);

  //   selectResult = await DB.select('SELECT * FROM $table');

  //   expect(selectResult.length, 1);

  //   expect(selectResult.first['id'], 1);
  //   expect(selectResult.first['email'], 'john-edited@gmail.com');
  //   expect(selectResult.first['password'], 'new-password');

  //   expect(selectResult.first['id'], 1);
  //   expect(selectResult.first['email'], 'john-edited@gmail.com');
  //   expect(selectResult.first['password'], 'new-password');
  // });

  // test('Rename table', () async {
  //   final table = 'users_19';
  //   final query =
  //       'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

  //   DB.unprepared(query);

  //   final renameQuery = Schema.rename(table, 'new_users');

  //   expect(renameQuery, 'ALTER TABLE $table RENAME TO new_users;');

  //   final result = await DB.select('SELECT * FROM new_users');

  //   expect(result.length, 0);
  // });

  // test('Drop table', () {
  //   final table = 'users_20';
  //   final query =
  //       'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL);';

  //   DB.statement(query);

  //   final dropQuery = Schema.drop(table);

  //   expect(dropQuery, 'DROP TABLE $table;');

  //   expect(() => DB.select('SELECT * FROM $table'),
  //       throwsA(isA<SqliteException>()));

  //   expect(Schema.dropIfExists(table), 'DROP TABLE IF EXISTS $table;');
  // });

  // test('Compound primary keys', () {
  //   final table = 'users_21';

  //   final query = Schema.create(table, (table) {
  //     table.string('id');
  //     table.string('email');
  //     table.string('password');
  //     table.primary(['id', 'email']);
  //   });

  //   expect(query,
  //       'CREATE TABLE $table (id VARCHAR(100) NOT NULL, email VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL, PRIMARY KEY (id, email));');
  // });

  // test('Update Schema', () {
  //   final table = 'users_22';

  //   final query = Schema.create(table, (table) {
  //     table.uuid();
  //     table.integer('employee_id').index();
  //     table.string('full_name');
  //     table.text('address');
  //     table.text('next_of_kin');
  //     table.string('next_of_kin_phone').index();

  //     table.index(['next_of_kin', 'next_of_kin_phone']);
  //   });

  //   expect(query,
  //       'CREATE TABLE $table (uuid CHAR(36) NOT NULL, employee_id INTEGER NOT NULL, full_name VARCHAR(100) NOT NULL, address TEXT NOT NULL, next_of_kin TEXT NOT NULL, next_of_kin_phone VARCHAR(100) NOT NULL);\nCREATE INDEX employee_id_index ON $table (employee_id);\nCREATE INDEX next_of_kin_phone_index ON users_22 (next_of_kin_phone);\nCREATE INDEX next_of_kin_next_of_kin_phone_index ON users_22 (next_of_kin, next_of_kin_phone);');

  //   final alterQuery = Schema.table(table, (table) {
  //     table.dropColumn('address');
  //     table.string('phone').index();
  //     table.renameColumn('full_name', 'first_name');
  //     table.dropIndex('employee_id_index');
  //   });

  //   expect(alterQuery,
  //       'ALTER TABLE $table ADD COLUMN phone VARCHAR(100);\nALTER TABLE $table DROP COLUMN address;\nALTER TABLE $table RENAME COLUMN full_name TO first_name;\nDROP INDEX employee_id_index;\nCREATE INDEX phone_index ON $table (phone);');
  // });
}
