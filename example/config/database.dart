import 'package:daravel_core/daravel_core.dart';

import '../core/helpers.dart';

@Config()
class Database {
  String defaultConnection = 'sqlite';

  Map<String, DatabaseConnection> connections = {
    'sqlite': DatabaseConnection(
      driver: 'sqlite',
      url: env('DB_URL'),
      database: 'database.sqlite',
      prefix: '',
      foreignKeyConstraints: env('DB_FOREIGN_KEYS', true),
    ),
  };
}
