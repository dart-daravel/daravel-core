import 'package:daravel_core/database/db.dart';
import 'package:daravel_core/database/db_connection.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

class Schema {
  /// Creates a table schema.
  static String create(
    String tableName,
    Function(Blueprint) buildFunction, {
    DBConnection? connection,
  }) {
    final blueprint = DB.connection()!.driver.initBlueprint(tableName, false);
    buildFunction(blueprint);
    return DB.connection()!.driver.executeBlueprint(blueprint);
  }

  static String table(String tableName, Function(Blueprint) buildFunction) {
    final blueprint = DB.connection()!.driver.initBlueprint(tableName, true);
    buildFunction(blueprint);
    return DB.connection()!.driver.executeBlueprint(blueprint);
  }

  /// Rename a table.
  static String rename(String from, String to) {
    return DB.connection()!.driver.renameTable(from, to);
  }

  /// Drop table.
  static String drop(String table) {
    return DB.connection()!.driver.drop(table);
  }

  /// Drop table if exists.
  static String dropIfExists(String table) {
    return DB.connection()!.driver.dropIfExists(table);
  }
}
