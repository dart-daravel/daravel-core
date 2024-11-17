import 'package:daravel_core/database/db.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

class Schema {
  /// Creates a table schema.
  ///
  /// [tableName] is the name of the table to be created.
  /// [buildFunction] is a function that takes a [Blueprint] object as an argument.
  /// make calls to the [Blueprint] object to define the schema.
  static String create(String tableName, Function(Blueprint) buildFunction) {
    final blueprint = DB.connection()!.driver.initBlueprint(tableName, false);
    buildFunction(blueprint);
    return DB.connection()!.driver.executeBlueprint(blueprint);
  }

  /// Use to update an existing table's schema.
  ///
  /// [tableName] is the name of the table to be updated.
  /// [buildFunction] is a function that takes a [Blueprint] object as an argument.
  /// make calls to the [Blueprint] object to define the schema to change.
  static String table(String tableName, Function(Blueprint) buildFunction) {
    final blueprint = DB.connection()!.driver.initBlueprint(tableName, true);
    buildFunction(blueprint);
    return DB.connection()!.driver.executeBlueprint(blueprint);
  }

  /// Rename a table.
  ///
  /// [from] is the current name of the table.
  /// [to] is the new name of the table.
  static String rename(String from, String to) {
    return DB.connection()!.driver.renameTable(from, to);
  }

  /// Drop table.
  ///
  /// [table] is the name of the table to drop.
  static String drop(String table) {
    return DB.connection()!.driver.dropTable(table);
  }

  /// Drop table if exists.
  ///
  /// [table] is the name of the table to drop.
  static String dropIfExists(String table) {
    return DB.connection()!.driver.dropTableIfExists(table);
  }
}
