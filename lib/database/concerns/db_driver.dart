import 'dart:async';

import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

abstract class DBDriver {
  /// Database insert mutex that allows inserts to be run in
  /// sequence so lastInsertIds don't get mixed up since we
  /// use a single connection to the database.
  late final DBInsertMutex insertMutex = DBInsertMutex();

  /// Execute a select query
  RecordSet? select(String query, [List<dynamic> bindings = const []]);

  /// Execute an insert query
  bool insert(String query, [List<dynamic> bindings = const []]);

  /// Execute an update query
  bool update(String query, [List<dynamic> bindings = const []]);

  /// Execute a delete query
  bool delete(String query, [List<dynamic> bindings = const []]);

  /// Execute a query
  bool statement(String query, [List<dynamic> bindings = const []]);

  /// Execute an unprepared query
  bool unprepared(String query);

  String executeBlueprint(Blueprint blueprint) {
    return '';
  }

  int? get lastInsertId;

  String renameTable(String from, String to);

  String drop(String table);

  String dropIfExists(String table);

  Blueprint initBlueprint(String name, bool modify);

  QueryBuilder queryBuilder([String? table]);

  void executeAlterBlueprint(Blueprint blueprint) {}
}

class DBInsertMutex {
  final _lock = Completer<void>();

  DBInsertMutex() {
    _lock.complete();
  }

  Future<void> acquire() async {
    if (!_lock.isCompleted) await _lock.future;
  }

  void release() {
    if (!_lock.isCompleted) _lock.complete();
  }
}
