import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

abstract class DBDriver {
  /// Execute a select query
  QueryResult? select(String query, [List<dynamic> bindings = const []]);

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

  String renameTable(String from, String to);

  String drop(String table);

  String dropIfExists(String table);

  Blueprint initBlueprint(String name, bool modify);

  void executeAlterBlueprint(Blueprint blueprint) {}
}
