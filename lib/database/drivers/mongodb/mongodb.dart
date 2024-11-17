import 'package:daravel_core/console/console_logger.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb_record.dart';
import 'package:daravel_core/exceptions/query.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:daravel_core/config/database_connection.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb_record_set.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:daravel_core/extensions/string.dart';

class MongoDBDriver extends DBDriver {
  late final Db? _db;

  late final DatabaseConnection _configuration;

  late final ConsoleLogger logger = ConsoleLogger();

  /// Initialize the MongoDB driver
  MongoDBDriver(DatabaseConnection connection) {
    final StringBuffer dsn = StringBuffer(connection.dsn != null
        ? '${connection.dsn!.rtrim('/')}/${connection.database}'
        : 'mongodb://localhost:27017');
    _db = Db(dsn.toString());
    _configuration = connection;
  }

  @override
  Future<void> boot() async {
    if (_db!.isConnected) {
      return;
    }
    await _db.open();
  }

  @override
  bool get logging => _configuration.queryLog;

  /// Run a select statement
  @override
  Future<RecordSet> select(String collection,
      [Object query = const {}, ORM? orm]) async {
    await boot();
    if (query is NoSqlQuery) {
      if (query.type != QueryType.select) {
        throw QueryException('Invalid query type');
      }
      final result = await _db!
          .collection(collection)
          .find(_buildQuery(collection, query))
          .toList();
      _logQuery(query);
      return MongodbRecordSet(result, orm);
    } else {
      throw ArgumentError('Query must be of type NoSqlQuery');
    }
  }

  @override
  Future<Record?> findOne(
    String collection,
    NoSqlQuery query,
  ) async {
    await boot();
    if (query.type != QueryType.select) {
      throw QueryException('Invalid query type');
    }
    final result = await _db!
        .collection(collection)
        .findOne(_buildQuery(collection, query));
    _logQuery(query);
    return result != null ? MongoDBRecord(result) : null;
  }

  @override
  Future<int> delete(String query, [Object bindings = const []]) =>
      throw UnimplementedError();

  /// Run an insert query.
  ///
  /// Throws [ArgumentError] if [query] is not of type
  /// [NoSqlQuery].
  ///
  /// Throws [QueryException] if [query] type is not [QueryType.insert].
  @override
  Future<Map<String, dynamic>> insert(String collection,
      [Object query = const {}]) async {
    await boot();
    if (query is NoSqlQuery) {
      if (query.type != QueryType.insert) {
        throw QueryException('Invalid query type');
      }
      final result = await _db!.collection(collection).insertOne(
            query.insertValues!,
            bypassDocumentValidation: query.bypassDocumentValidation,
          );
      _logQuery(query);
      return result.document!;
    } else {
      throw ArgumentError('Query must be of type NoSqlQuery');
    }
  }

  @override
  Future<int> insertGetId(String query, [List bindings = const []]) =>
      throw UnimplementedError();

  /// Run an SQL statement.
  @override
  Future<bool> statement(String query, [List bindings = const []]) =>
      throw UnimplementedError('Operation Not supported with MongoDB driver.');

  /// Run an unprepared query.
  @override
  bool unprepared(String query) =>
      throw UnimplementedError('Operation Not supported with MongoDB driver.');

  /// Run an update query.
  @override
  Future<int> update(String query, [List bindings = const []]) async =>
      throw UnimplementedError();

  @override
  String executeBlueprint(Blueprint blueprint) => throw UnimplementedError();

  @override
  Blueprint initBlueprint(String name, bool modify) =>
      throw UnimplementedError();

  @override
  String dropTable(String table) => throw UnimplementedError();

  @override
  String dropTableIfExists(String table) => throw UnimplementedError();

  @override
  String renameTable(String from, String to) => throw UnimplementedError();

  @override
  QueryBuilder queryBuilder([String? table, ORM? orm]) =>
      throw UnimplementedError();

  Map<String, Object> _buildQuery(String collection, NoSqlQuery query) {
    final Map<String, Object> preparedQuery = {};

    if ((query.selectFields ?? []).isNotEmpty) {
      final builder = SelectorBuilder()..fields(query.selectFields!);
      preparedQuery.addAll(builder.map as Map<String, Object>);
    }

    if (query.whereMap != null) {
      preparedQuery.addAll(query.whereMap!);
    }

    return preparedQuery;
  }

  @override
  Object? get nativeConnectionInstance => _db;

  /// Log BSON query.
  _logQuery(NoSqlQuery query) {
    if (_configuration.queryLog) {
      logger.debug(query.toString());
    }
  }
}
