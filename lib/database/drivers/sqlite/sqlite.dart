import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/schema/sqlite_blueprint.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_query_builder.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_schema_builder.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteDriver extends DBDriver {
  late final Database? _db;

  late final Database? _insertDb;
  late final Database? _updateDb;
  late final Database? _deleteDb;

  late final SqliteSchemaBuilder _schemaBuilder = SqliteSchemaBuilder(this);

  late final DatabaseConnection _configuration;

  SQLiteDriver(DatabaseConnection connection) {
    _db = sqlite3
        .open(connection.url ?? connection.database ?? 'database.sqlite');
    _insertDb = sqlite3
        .open(connection.url ?? connection.database ?? 'database.sqlite');
    _updateDb = sqlite3
        .open(connection.url ?? connection.database ?? 'database.sqlite');
    _deleteDb = sqlite3
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
  RecordSet select(String query, [List bindings = const [], ORM? orm]) {
    final statement = _db!.prepare(query);
    return SqliteRecordSet(statement.select(bindings), orm);
  }

  /// Run a delete query
  /// Throws [ArgumentError] if length of [bindings] is not equal number of
  /// placeholders in query.
  @override
  Future<int> delete(String query, [List bindings = const []]) async {
    final statement = _deleteDb!.prepare(query);
    await deleteMutex.acquire();
    try {
      statement.execute(bindings);
      return _deleteDb.updatedRows;
    } finally {
      deleteMutex.release();
    }
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

  @override
  Future<int> insertGetId(String query, [List bindings = const []]) async {
    final statement = _insertDb!.prepare(query);
    await insertMutex.acquire();
    try {
      statement.execute(bindings);
      return _insertDb.lastInsertRowId;
    } finally {
      insertMutex.release();
    }
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
  Future<int> update(String query, [List bindings = const []]) async {
    final statement = _updateDb!.prepare(query);
    await updateMutex.acquire();
    try {
      statement.execute(bindings);
      return _updateDb.updatedRows;
    } finally {
      updateMutex.release();
    }
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
  QueryBuilder queryBuilder([String? table, ORM? orm]) =>
      SQLiteQueryBuilder(this, table, orm);
}
