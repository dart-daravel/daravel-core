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
    return DB.connection()!.createTable(blueprint);
  }
}
