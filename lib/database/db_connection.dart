import 'dart:async';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite.dart';

class DBConnection {
  late final DBDriver driver;

  DBConnection(DatabaseConnection connection) {
    switch (connection.driver) {
      case 'sqlite':
        driver = SQLiteDriver(connection);
        break;
      case 'mongodb':
        driver = MongoDBDriver(connection);
        break;
      default:
        throw Exception('Driver not found');
    }
  }

  FutureOr<RecordSet> select(String query,
      [List<dynamic> bindings = const []]) {
    return driver.select(query, bindings);
  }

  Future<Record?> findOne(String collection, NoSqlQuery query) =>
      driver.findOne(collection, query);

  Future<bool> statement(String query,
      [List<dynamic> bindings = const []]) async {
    return await driver.statement(query, bindings);
  }

  /// If using MongoDB driver, [query] is the name of the collection
  /// to insert a document into.
  Future<Object> insert(String query, [Object bindings = const []]) async {
    return driver.insert(query, bindings);
  }

  Future<int> delete(String query, [List<dynamic> bindings = const []]) {
    return driver.delete(query, bindings);
  }

  Future<int> update(String query, [List<dynamic> bindings = const []]) async {
    return await driver.update(query, bindings);
  }

  bool unprepared(String query) {
    return driver.unprepared(query);
  }

  Future<void> drop(String database) async {}
}
