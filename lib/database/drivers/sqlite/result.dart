import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:sqlite3/sqlite3.dart';

class Result implements QueryResult {
  ResultSet result;

  Result(this.result);

  @override
  List<List<Object?>> get rows => result.rows;
}
