import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:daravel_core/database/drivers/sqlite/result.dart';
import 'package:daravel_core/database/drivers/sqlite/schema/sqlite_blueprint.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_schema_builder.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteDriver extends DBDriver {
  late final Database? _db;

  late final SqliteSchemaBuilder _schemaBuilder = SqliteSchemaBuilder(this);

  SQLiteDriver(DatabaseConnection connection) {
    _db = sqlite3
        .open(connection.url ?? connection.database ?? 'database.sqlite');
    if (connection.foreignKeyConstraints ?? false) {
      _db?.execute('PRAGMA foreign_keys = ON;');
    }
    if (connection.busyTimeout != null) {
      _db?.execute('PRAGMA busy_timeout = ${connection.busyTimeout};');
    }
  }

  /// Run a select statement
  @override
  QueryResult select(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    return Result(statement.select(bindings));
  }

  /// Run a delete query
  /// Throws [ArgumentError] if length of [bindings] is not equal number of
  /// placeholders in query.
  @override
  bool delete(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    statement.execute(bindings);
    return true;
  }

  /// Run an insert query.
  /// Throws [ArgumentError] if length of [bindings] is not equal number of
  /// placeholders in query.
  @override
  bool insert(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    statement.execute(bindings);
    return true;
  }

  /// Run an SQL statement.
  @override
  bool statement(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    statement.execute(bindings);
    return true;
  }

  /// Run an unprepared query.
  @override
  bool unprepared(String query) {
    _db!.execute(query);
    return true;
  }

  /// Run an update query.
  @override
  bool update(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    statement.execute(bindings);
    return true;
  }

  @override
  String executeCreateBlueprint(Blueprint blueprint) {
    return _schemaBuilder.executeCreateBlueprint(blueprint);
  }

  @override
  Blueprint initBlueprint(String name, bool modify) {
    return SqliteBlueprint(name, modify);
  }

  @override
  String drop(String table) {
    // TODO: implement drop
    throw UnimplementedError();
  }

  @override
  String dropIfExists(String table) {
    // TODO: implement dropIfExists
    throw UnimplementedError();
  }

  @override
  String renameTable(String from, String to) {
    return _schemaBuilder.renameTable(from, to);
  }
}
