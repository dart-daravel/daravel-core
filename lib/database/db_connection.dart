import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

class DBConnection {
  late final DBDriver driver;

  DBConnection(DatabaseConnection connection) {
    switch (connection.driver) {
      case 'sqlite':
        driver = SQLiteDriver(connection);
        break;
      default:
        throw Exception('Driver not found');
    }
  }

  QueryResult? select(String query, [List<dynamic> bindings = const []]) {
    return driver.select(query, bindings);
  }

  String createTable(Blueprint blueprint) {
    return driver.executeCreateBlueprint(blueprint);
  }
}
