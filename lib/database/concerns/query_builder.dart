import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_result.dart';

abstract class QueryBuilder {
  String? table;

  DBDriver driver;

  QueryBuilder(this.driver, [this.table]);

  QueryResult get();

  QueryBuilder select(dynamic columns);
}

enum QueryType { select, insert, update, delete }
