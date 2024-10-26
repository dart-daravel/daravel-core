import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/db_connection.dart';
import 'package:daravel_core/database/concerns/query_result.dart';

class DB {
  /// Main instance of the database connection.
  static DB? _mainInstance;

  static final Map<String, DB> _instances = {};

  DB._();

  late final Core? _core;

  DBConnection? _dbConnection;

  Map<String, DatabaseConnection>? connections;

  QueryResult? select(String query, [List<dynamic> bindings = const []]) {
    return _dbConnection!.select(query, bindings);
  }

  static DBConnection? connection([String? connection]) {
    if (_mainInstance?._core == null) {
      throw ComponentNotBootedException('Database system not booted.');
    }

    if (connection == null) {
      return _mainInstance!._dbConnection;
    }

    if (_instances.keys.contains(connection)) {
      return _instances[connection]!._dbConnection;
    }

    final instance = DB._();

    if (!_mainInstance!._core!.configMap[_ConfigKeys.connections].keys
        .contains(connection)) {
      throw DBConnectionNotFoundException(connection);
    }

    instance._dbConnection = DBConnection(_mainInstance!._core!
        .configMap[_ConfigKeys.connections][connection] as DatabaseConnection);

    _instances[connection] = instance;

    return instance._dbConnection;
  }

  /// Set the default connection.
  static void setDefaultConnection(String connection) =>
      _mainInstance!._dbConnection = DB.connection(connection);

  /// Boot.
  static void boot(Core core) {
    _mainInstance ??= DB._();
    _mainInstance!._core = core;
    _mainInstance!._dbConnection = DBConnection(core
            .configMap[_ConfigKeys.connections]
        [core.configMap[_ConfigKeys.defaultConnection]] as DatabaseConnection);
  }
}

class _ConfigKeys {
  static const String defaultConnection = 'database.defaultConnection';
  static const String connections = 'database.connections';
}
