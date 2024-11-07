import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class User extends Model {}

class User2 extends Model {
  @override
  String? get table => 'users_1';
}

void main() {
  setUpAll(() {
    Directory(
            path.join(Directory.current.path, 'test/database-model-playground'))
        .createSync(recursive: true);

    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-model-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
          queryLog: true,
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(
            path.join(Directory.current.path, 'test/database-model-playground'))
        .deleteSync(recursive: true);
  });

  test('Model all()', () {
    final table = 'users';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    User().create({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    User().create({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    User().create({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    final users = User().all();

    expect(users, isA<RecordSet>());
    expect(users.length, 3);
  });

  test('Model all() with custom table name', () {
    final table = 'users_1';

    Schema.create(table, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    DB.table(table).insert({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    DB.table(table).insert({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    DB.table(table).insert({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    final users = User2().all();

    expect(users, isA<RecordSet>());
    expect(users.length, 3);
  });
}
