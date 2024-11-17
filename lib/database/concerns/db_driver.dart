import 'dart:async';

import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

abstract class DBDriver {
  /// Database insert mutex that allows inserts to be run in
  /// sequence so lastInsertIds don't get mixed up since we
  /// use a single connection to the database.
  late final DBMutex insertMutex = DBMutex();

  /// Database update mutex that allows updates to be run in
  /// sequence so number of affected rows don't get mixed up
  /// since we use a single connection to the database.
  late final DBMutex updateMutex = DBMutex();

  /// Database delete mutex that allows deletes to be run in
  /// sequence so number of affected rows don't get mixed up
  /// since we use a single connection to the database.
  late final DBMutex deleteMutex = DBMutex();

  Future<void> boot();

  /// Execute a select query
  FutureOr<RecordSet> select(String query,
      [Object bindings = const [], ORM? orm]);

  Future<Record?> findOne(String collection, NoSqlQuery query);

  /// Execute an insert query
  Future<Object> insert(String query, [Object bindings = const []]);

  Future<int> insertGetId(String query, [List<dynamic> bindings = const []]);

  /// Execute an update query
  Future<int> update(String query, [List<dynamic> bindings = const []]);

  /// Execute a delete query
  Future<int> delete(String query, [List<dynamic> bindings = const []]);

  /// Execute a query
  Future<bool> statement(String query, [List<dynamic> bindings = const []]);

  /// Execute an unprepared query
  bool unprepared(String query);

  String executeBlueprint(Blueprint blueprint) {
    return '';
  }

  bool get logging;

  Object? get nativeConnectionInstance;

  String renameTable(String from, String to);

  String dropTable(String table);

  String dropTableIfExists(String table);

  Blueprint initBlueprint(String name, bool modify);

  QueryBuilder queryBuilder([String? table, ORM? orm]);

  void executeAlterBlueprint(Blueprint blueprint) {}
}

class DBMutex {
  final _lock = Completer<void>();

  DBMutex() {
    _lock.complete();
  }

  Future<void> acquire() async {
    if (!_lock.isCompleted) await _lock.future;
  }

  void release() {
    if (!_lock.isCompleted) _lock.complete();
  }
}
