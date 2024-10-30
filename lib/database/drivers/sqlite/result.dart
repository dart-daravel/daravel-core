import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:sqlite3/sqlite3.dart';

class Result implements QueryResult {
  ResultSet result;
  List<Map<String, Object?>>? _mappedRows;

  Result(this.result);

  @override
  List<List<Object?>> get rows => result.rows;

  @override
  List<Map<String, Object?>> get mappedRows {
    _mappedRows ??= result.rows.map((e) {
      final map = <String, Object?>{};
      for (var x = 0; x < result.columnNames.length; x++) {
        map[result.columnNames[x]] = e[x];
      }
      return map;
    }).toList();
    return _mappedRows!;
  }

  @override
  Object? get resultObject => result;
}
