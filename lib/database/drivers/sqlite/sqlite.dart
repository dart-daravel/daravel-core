import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/schema/sqlite_blueprint.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_query_builder.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_schema_builder.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteDriver extends DBDriver {
  late final Database? _db;

  late final SqliteSchemaBuilder _schemaBuilder = SqliteSchemaBuilder(this);

  late final DatabaseConnection _configuration;

  SQLiteDriver(DatabaseConnection connection) {
    _db = sqlite3
        .open(connection.url ?? connection.database ?? 'database.sqlite');
    if (connection.foreignKeyConstraints ?? false) {
      _db?.execute('PRAGMA foreign_keys = ON;');
    }
    if (connection.busyTimeout != null) {
      _db?.execute('PRAGMA busy_timeout = ${connection.busyTimeout};');
    }
    _configuration = connection;
  }

  @override
  bool get logging => _configuration.queryLog;

  /// Run a select statement
  @override
  RecordSet select(String query, [List bindings = const []]) {
    final statement = _db!.prepare(query);
    return SqliteRecordSet(statement.select(bindings));
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
  String executeBlueprint(Blueprint blueprint) {
    return _schemaBuilder.executeBlueprint(blueprint);
  }

  @override
  Blueprint initBlueprint(String name, bool modify) {
    return SqliteBlueprint(name, modify);
  }

  @override
  String drop(String table) {
    return _schemaBuilder.drop(table);
  }

  @override
  String dropIfExists(String table) {
    return _schemaBuilder.dropIfExists(table);
  }

  @override
  String renameTable(String from, String to) {
    return _schemaBuilder.renameTable(from, to);
  }

  @override
  QueryBuilder queryBuilder([String? table]) => SQLiteQueryBuilder(this, table);

  @override
  int? get lastInsertId => _db?.lastInsertRowId;

  @override
  int? get affectedRows => _db?.updatedRows;
}
