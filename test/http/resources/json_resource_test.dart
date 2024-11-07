import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/http/resources/json/json_resource.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class UserResource extends JsonResource<Entity> {
  UserResource(super.data);

  @override
  List<String> get hidden => ['password'];

  @override
  int get statusCode => 200;

  @override
  Map toJson() {
    return data.toJson();
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
}
