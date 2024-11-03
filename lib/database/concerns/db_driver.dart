import 'dart:async';

import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
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

  /// Execute a select query
  RecordSet? select(String query, [List<dynamic> bindings = const []]);

  /// Execute an insert query
  bool insert(String query, [List<dynamic> bindings = const []]);

  Future<int> insertGetId(String query, [List<dynamic> bindings = const []]);

  /// Execute an update query
  Future<int> update(String query, [List<dynamic> bindings = const []]);

  /// Execute a delete query
  Future<int> delete(String query, [List<dynamic> bindings = const []]);

  /// Execute a query
  bool statement(String query, [List<dynamic> bindings = const []]);

  /// Execute an unprepared query
  bool unprepared(String query);

  String executeBlueprint(Blueprint blueprint) {
    return '';
  }

  int? get lastInsertId;

  int? get affectedRows;

  bool get logging;

  String renameTable(String from, String to);

  String drop(String table);

  String dropIfExists(String table);

  Blueprint initBlueprint(String name, bool modify);

  QueryBuilder queryBuilder([String? table]);

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
