import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';

abstract class QueryBuilder {
  String? table;

  DBDriver driver;

  QueryBuilder(this.driver, [this.table]);

  RecordSet get();

  Record? first();

  Record firstOrFail();

  QueryBuilder limit(int limit, [int? offset]);

  Object? value(String column);

  Record? find(dynamic id);

  List<Object?> pluck(String column);

  QueryBuilder orderBy(String column, [String direction = 'ASC']);

  void chunk(int size, bool? Function(RecordSet records) callback);

  void chunkById(int size, bool? Function(RecordSet records) callback);

  QueryBuilder where(dynamic column, dynamic operatorOrValue, [dynamic value]);

  QueryBuilder orWhere(String column, dynamic operatorOrValue, [dynamic value]);

  QueryBuilder select(dynamic columns);
}

enum QueryType { select, insert, update, delete }

class WhereClause {
  final String column;
  final String operator;
  final dynamic value;

  String concatenator;

  WhereClause({
    required this.column,
    required this.operator,
    required this.value,
    this.concatenator = 'AND',
  });
}
