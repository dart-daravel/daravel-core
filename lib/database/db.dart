import 'dart:async';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/db_connection.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/component_not_booted.dart';
import 'package:daravel_core/exceptions/db_connection_not_found.dart';

class DB {
  /// Main instance of the database connection.
  static DB? _mainInstance;

  static final Map<String, DB> _instances = {};

  DB._();

  late final Core? _core;

  DBConnection? _dbConnection;

  Map<String, DatabaseConnection>? connections;

  static FutureOr<RecordSet> select(String query,
          [List<dynamic> bindings = const []]) =>
      _mainInstance!._dbConnection!.select(query, bindings);

  static bool statement(String query, [List<dynamic> bindings = const []]) =>
      _mainInstance!._dbConnection!.statement(query, bindings);

  static bool insert(String query, [List<dynamic> bindings = const []]) =>
      _mainInstance!._dbConnection!.insert(query, bindings);

  static Future<int> delete(String query,
          [List<dynamic> bindings = const []]) =>
      _mainInstance!._dbConnection!.delete(query, bindings);

  static Future<int> update(String query,
          [List<dynamic> bindings = const []]) =>
      _mainInstance!._dbConnection!.update(query, bindings);

  /// Execute an unprepared statement.
  static bool unprepared(String query) =>
      _mainInstance!._dbConnection!.unprepared(query);

  /// Gets a Database connection instance.
  ///
  /// [connection] Optional, the connection instance to obtain based on the
  /// [connections] list in your database.dart config.
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

  /// Gets a query builder.
  static QueryBuilder table(String table) =>
      _mainInstance!._dbConnection!.driver.queryBuilder(table);

  static raw(String query, [List bindings = const []]) =>
      RawQueryComponent(query, bindings);
}

class _ConfigKeys {
  static const String defaultConnection = 'database.defaultConnection';
  static const String connections = 'database.connections';
}
