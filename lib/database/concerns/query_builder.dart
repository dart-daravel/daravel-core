import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';

abstract class QueryBuilder {
  String? table;

  DBDriver driver;

  QueryBuilder(this.driver, [this.table]); // ignore: coverage

  RecordSet get();

  Record? first();

  Record firstOrFail();

  QueryBuilder limit(int limit, [int? offset]);

  Object? value(String column);

  Record? find(dynamic id);

  Future<int> insert(Map<String, dynamic> values);

  Future<int> update(Map<String, dynamic> values);

  List<Object?> pluck(String column);

  QueryBuilder orderBy(String column, [String direction = 'ASC']);

  void chunk(int size, bool? Function(RecordSet records) callback);

  void chunkById(int size, bool? Function(RecordSet records) callback);

  QueryBuilder where(dynamic column, [dynamic operatorOrValue, dynamic value]);

  QueryBuilder orWhere(dynamic column,
      [dynamic operatorOrValue, dynamic value]);

  QueryBuilder select(dynamic columns);

  LazyRecordSetGenerator lazy();

  LazyRecordSetGenerator lazyById();

  int count([String columns = '*']);

  int max(String column);

  int min(String column);

  int sum(String column);

  num avg(String column);

  bool exists();

  bool doesntExist();
}

enum QueryType { select, insert, update, delete }

class WhereClause {
  final String? column;
  final String? operator;
  final dynamic value;

  final bool isOpenBracket;
  final bool isCloseBracket;

  String concatenator;

  WhereClause({
    this.column,
    this.operator,
    this.value,
    this.isOpenBracket = false,
    this.isCloseBracket = false,
    this.concatenator = 'AND',
  });
}

abstract class LazyRecordSetGenerator {
  String selectQuery;

  DBDriver driver;

  int bufferSize;

  LazyRecordSetGenerator(this.driver, this.selectQuery, this.bufferSize);

  Future<void> each(bool? Function(Record record) callback);
}
