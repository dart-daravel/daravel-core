import 'dart:convert';
import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/http/resources/json/json_resource.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class User extends Model {}

class UserResource extends JsonResource<Entity> {
  UserResource(super.data);

  @override
  List<String> get hidden => [
        'password',
        'user.password',
      ];

  @override
  int get statusCode => 200;

  @override
  Map toJson() {
    final json = data.toJson();
    json['user'] = data.toJson();
    return json;
  }
}

void main() {
  setUpAll(() {
    Directory(path.join(
            Directory.current.path, 'test/database-json-resource-playground'))
        .createSync(recursive: true);

    expect(() => DB.connection(), throwsA(isA<ComponentNotBootedException>()));

    DB.boot(Core(configMap: {
      'database.defaultConnection': 'sqlite',
      'database.connections': {
        'sqlite': DatabaseConnection(
          driver: 'sqlite',
          database: 'test/database-json-resource-playground/database.sqlite',
          prefix: '',
          foreignKeyConstraints: true,
          queryLog: true,
        ),
      }
    }));
  });

  tearDownAll(() {
    Directory(path.join(
            Directory.current.path, 'test/database-json-resource-playground'))
        .deleteSync(recursive: true);
  });

  test('JSON Response', () async {
    final userModel = User();

    Schema.create(userModel.tableName, (table) {
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

    final user = userModel.find(1);

    final response =
        json.decode(await UserResource(user!).toJsonResponse().readAsString());

    expect(response['email'], 'tok@gmail.com');
    expect(response['password'], null);
    expect(response['user']['email'], 'tok@gmail.com');
    expect(response['user']['password'], null);
  });
}
