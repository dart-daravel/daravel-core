import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite.dart';

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

  RecordSet? select(String query, [List<dynamic> bindings = const []]) {
    return driver.select(query, bindings);
  }

  bool statement(String query, [List<dynamic> bindings = const []]) {
    return driver.statement(query, bindings);
  }

  bool insert(String query, [List<dynamic> bindings = const []]) {
    return driver.insert(query, bindings);
  }

  bool delete(String query, [List<dynamic> bindings = const []]) {
    return driver.delete(query, bindings);
  }

  bool update(String query, [List<dynamic> bindings = const []]) {
    return driver.update(query, bindings);
  }

  bool unprepared(String query) {
    return driver.unprepared(query);
  }
}
