import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
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

    expect(result.rows.length, 1);
    expect(result.mappedRows!.first['email'], 'frank@gmail.com');
    expect(result.mappedRows!.first['password'], 'password');
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

    expect(result.rows.length, 1);
    expect(result.mappedRows!.first['email'], 'frank@gmail.com');
  });
}
