import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb_query_builder.dart';
import 'package:daravel_core/extensions/string.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDBDriver extends DBDriver {
  late final Db? _db;

  late final MongoDBSchemaBuilder _schemaBuilder = MongoDBSchemaBuilder(this);

  late final DatabaseConnection _configuration;

  MongoDBDriver(DatabaseConnection connection) {
    _db = Db(connection.dsn != null
        ? '${connection.dsn!.rtrim('/')}/${connection.database}'
        : 'mongodb://localhost:27017');
    _db!.open();
    _configuration = connection;
  }

  @override
  bool get logging => _configuration.queryLog;

  /// Run a select statement
  @override
  RecordSet select(String collection, [List bindings = const []]) {
    final result = _db!.collection(collection).find().toList();
    return RecordSet(cursor);
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
    return MongoDBBlueprint(name, modify);
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
  QueryBuilder queryBuilder([String? table]) =>
      MongoDBQueryBuilder(this, table);
}
