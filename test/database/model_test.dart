import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class User extends Model {}

class User2 extends Model {
  @override
  String? get table => 'users_2';
}

// Model hasMany Relationship Models - Start
class User3 extends Model {
  @override
  String? get table => 'users_3';

  @override
  Map<String, Function> get relationships => {
        'posts': () => hasMany(Post, foreignKey: 'user_id'),
      };
}

class Post extends Model {
  @override
  Map<String, Function> get relationships => {
        'user': () => belongsTo(User3),
      };
}
// Model hasMany Relationship Models - End

// Model belongsToMany Relationship Models - Start
class User4 extends Model {
  @override
  String? get table => 'users_4';
}

class Status extends Model {
  @override
  Map<String, Function> get relationships => {
        'users': () => belongsToMany(User4, foreignTable: 'users_4'),
      };
}
// Model belongsToMany Relationship Models - End

// Model hasOne & belongsTo Relationship Models - Start
class Employee extends Model {
  @override
  Map<String, Function> get relationships => {
        'address': () => hasOne(Address),
      };
}

class Address extends Model {
  @override
  Map<String, Function> get relationships => {
        'employee': () => belongsTo(Employee),
      };
}
// Model hasOne & belongsTo Relationship Models - End

class User5 extends Model {
  @override
  String? get table => 'users_5';
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

    expect(users, isA<List<Entity>>());
    expect(users.length, 3);

    // orWhere clause
    final users2 = User().where('id', 1).orWhere('id', 2).get();

    expect(users2, isA<RecordSet>());
    expect(users2.length, 2);

    // Query Builder
    final user = User().query().where('id', 1).first();

    expect(user, isA<Entity>());
    expect(user!['id'], 1);
  });

  test('Model all() with custom table name', () {
    final userModel = User2();

    Schema.create(userModel.tableName, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    userModel.create({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    userModel.create({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    userModel.create({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    final users = User2().all();

    expect(users, isA<List<Entity>>());
    expect(users.length, 3);

    // Where clause
    final user = User2().where('id', 1).first();
    expect(user, isA<Entity>());
    expect(user!['id'], 1);
  });

  test('Model hasOne & belongsTo Relationship', () {
    final employeeModel = Employee();
    final addressModel = Address();

    Schema.create(employeeModel.tableName, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    Schema.create(addressModel.tableName, (table) {
      table.increments('id');
      table.string('address');
      table.integer('employee_id');
      table.integer('building_floors');

      table.foreign('employee_id').references('id').on(employeeModel.tableName);
    });

    employeeModel.create({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    employeeModel.create({
      'email': 'tak@gmail.com',
      'password': 'password',
      'name': 'Tak',
      'address': 'Mars',
      'age': 25
    });

    employeeModel.create({
      'email': 'jack@gmail.com',
      'password': 'password',
      'name': 'Jack',
      'address': 'Pluto',
      'age': 19
    });

    addressModel.create({
      'address': 'Earth',
      'employee_id': 1,
      'building_floors': 5,
    });

    addressModel.create({
      'address': 'Mars',
      'employee_id': 2,
      'building_floors': 10,
    });

    addressModel.create({
      'address': 'Pluto',
      'employee_id': 3,
      'building_floors': 15,
    });

    // hasOne
    final user = employeeModel.where('id', 1).first();
    final address = user!['=address'];

    expect(user, isA<Entity>());
    expect(address, isA<Entity>());

    expect(address!['address'], 'Earth');
    expect(address['building_floors'], 5);

    // belongsTo
    final address2 = addressModel.where('id', 3).first();

    expect(address2, isA<Entity>());
    expect(address2!['=employee']['name'], 'Jack');

    // Invoke hasOne
    final address3 = (user['=address()'] as QueryBuilder)
        .where('address', 'Mercury')
        .first();

    expect(address3, null);

    // Invoke belongsTo
    final user2 =
        (address2['=employee()'] as QueryBuilder).where('name', 'Jack').first();

    expect(user2, isA<Entity>());
    expect(user2!['name'], 'Jack');
  });

  test('Model hasMany Relationship', () {
    final userModel = User3();
    final postModel = Post();

    Schema.create(userModel.tableName, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    Schema.create(postModel.tableName, (table) {
      table.increments('id');
      table.string('title');
      table.string('content');
      table.integer('user_id');
      table.integer('likes');

      table.foreign('user_id').references('id').on(userModel.tableName);
    });

    userModel.create({
      'email': 'tok@gmail.com',
      'password': 'password',
      'name': 'Jon',
      'address': 'Earth',
      'age': 20
    });

    postModel.create({
      'title': 'Post 1',
      'content': 'Content 1',
      'likes': 10,
      'user_id': 1,
    });

    postModel.create({
      'title': 'Post 2',
      'content': 'Content 2',
      'likes': 20,
      'user_id': 1,
    });

    postModel.create({
      'title': 'Post 3',
      'content': 'Content 3',
      'likes': 30,
      'user_id': 1,
    });

    final user = userModel.first();
    final posts = user!['=posts'] as RecordSet;

    expect(user, isA<Entity>());
    expect(posts, isA<RecordSet>());
    expect(posts.length, 3);
    expect(posts[0]['title'], 'Post 1');

    // Invoke
    final post = user['=posts()'].where('title', 'Post 2').first() as Entity;
    expect(post['title'], 'Post 2');
  });

  test('belongsToMany', () {
    final userModel = User4();
    final statusModel = Status();

    Schema.create(statusModel.tableName, (table) {
      table.increments('id');
      table.string('name');
    });

    Schema.create(userModel.tableName, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('status_id');
      table.integer('age');

      table.foreign('status_id').references('id').on(statusModel.tableName);
    });

    statusModel.create({
      'name': 'Active',
    });

    statusModel.create({
      'name': 'Inactive',
    });

    userModel.create({
      'email': 'a@gmail.com',
      'password': 'password',
      'name': 'A',
      'address': 'Earth',
      'status_id': 1,
      'age': 20
    });

    userModel.create({
      'email': 'b@gmail.com',
      'password': 'password',
      'name': 'B',
      'address': 'Mars',
      'status_id': 1,
      'age': 25
    });

    userModel.create({
      'email': 'c@gmail.com',
      'password': 'password',
      'name': 'C',
      'address': 'Pluto',
      'status_id': 2,
      'age': 19
    });

    final status = statusModel.where('id', 1).first();
    final users = status!['=users'] as RecordSet;

    expect(status, isA<Entity>());

    expect(users, isA<RecordSet>());
    expect(users.length, 2);
    expect(users.first['name'], 'A');

    // Invoke
    final user = status['=users()'].where('name', 'A').first() as Entity;
    expect(user['name'], 'A');
  });

  test('chunk and chunkById', () {
    final userModel = User5();

    Schema.create(userModel.tableName, (table) {
      table.increments('id');
      table.string('email');
      table.string('password');
      table.string('name');
      table.string('address');
      table.integer('age');
    });

    userModel.create({
      'email': 'a@gmail.com',
      'password': 'password',
      'name': 'A',
      'address': 'Earth',
      'age': 20
    });

    userModel.create({
      'email': 'b@gmail.com',
      'password': 'password',
      'name': 'B',
      'address': 'Mars',
      'age': 25
    });

    userModel.create({
      'email': 'c@gmail.com',
      'password': 'password',
      'name': 'C',
      'address': 'Pluto',
      'age': 19
    });

    int chunks = 0;

    userModel.chunk(2, (users) {
      expect(users, isA<RecordSet>());
      expect(users.length, chunks == 0 ? 2 : 1);
      chunks++;
      return true;
    });

    expect(chunks, 2);

    chunks = 0;

    userModel.chunkById(2, (users) {
      expect(users, isA<RecordSet>());
      expect(users.length, chunks == 0 ? 2 : 1);
      chunks++;
      return true;
    });

    expect(chunks, 2);
  });
}
