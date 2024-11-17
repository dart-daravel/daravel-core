import 'dart:async';
import 'dart:convert';

import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/orm/orm.dart';

abstract class QueryBuilder {
  String? table;

  DBDriver driver;

  ORM? orm;

  QueryBuilder(this.driver, [this.table, this.orm]); // ignore: coverage

  Future<RecordSet> get();

  Future<Record?> first();

  Future<Record> firstOrFail();

  QueryBuilder limit(int limit, [int? offset]);

  Future<Object?> value(String column);

  Future<Record?> find(dynamic id);

  bool insert(Map<String, dynamic> values);

  Future<int> insertGetId(Map<String, dynamic> values);

  Future<int> update(Map<String, dynamic> values);

  Future<int> delete([Object? id]);

  Future<List<Object?>> pluck(String column);

  QueryBuilder orderBy(String column, [String direction = 'ASC']);

  Future<void> chunk(int size, bool? Function(RecordSet records) callback);

  Future<void> chunkById(int size, bool? Function(RecordSet records) callback);

  QueryBuilder where(dynamic column, [dynamic operatorOrValue, dynamic value]);

  Future<QueryBuilder> whereAsync(Function(QueryBuilder) where);

  QueryBuilder orWhere(dynamic column,
      [dynamic operatorOrValue, dynamic value]);

  QueryBuilder select(dynamic columns);

  LazyRecordSetGenerator lazy();

  LazyRecordSetGenerator lazyById();

  Future<int> count([String columns = '*']);

  Future<int> max(String column);

  Future<int> min(String column);

  Future<int> sum(String column);

  Future<num> avg(String column);

  Future<bool> exists();

  Future<bool> doesntExist();

  QueryBuilder distinct();

  QueryBuilder addSelect(String column);

  QueryBuilder selectRaw(String rawSelect, [List bindings]);

  QueryBuilder whereRaw(String rawWhere, [List bindings]);

  QueryBuilder orWhereRaw(String rawWhere, [List bindings]);

  QueryBuilder groupBy(String column);
}

enum QueryType { select, insert, update, delete }

class WhereClause {
  final String? column;
  final String? operator;
  final dynamic value;
  final String? rawClause;
  final List? rawBindings;

  final bool isOpenBracket;
  final bool isCloseBracket;

  String concatenator;

  WhereClause({
    this.column,
    this.operator,
    this.value,
    this.rawClause,
    this.rawBindings,
    this.isOpenBracket = false,
    this.isCloseBracket = false,
    this.concatenator = 'AND',
  });
}

abstract class LazyRecordSetGenerator {
  QueryStringBinding selectQuery;

  DBDriver driver;

  int bufferSize;

  QueryBuilder queryBuilder;

  LazyRecordSetGenerator(
      this.driver, this.selectQuery, this.bufferSize, this.queryBuilder);

  Future<void> each(bool? Function(Record record) callback);
}

class QueryStringBinding {
  final String query;
  final List bindings;

  QueryStringBinding(this.query, this.bindings);

  Future<String> getUnsafeQuery() async {
    final varPattern = RegExp(r'\?');
    final tempBindings = List.from(bindings);

    return query.replaceAllMapped(varPattern, (match) {
      final value = tempBindings.removeAt(0);
      if (value is String) {
        return "'$value'";
      }
      return value.toString();
    });
  }
}

class NoSqlQuery {
  final QueryType type;
  final List<String>? selectFields;
  final Map<String, Object>? whereMap;
  final Map<String, dynamic>? insertValues;
  final Map<String, dynamic>? updateValues;
  final bool? bypassDocumentValidation;
  final bool? findOne;

  NoSqlQuery({
    this.type = QueryType.select,
    this.findOne,
    this.selectFields,
    this.whereMap,
    this.insertValues,
    this.updateValues,
    this.bypassDocumentValidation,
  });

  @override
  String toString() {
    final StringBuffer queryString = StringBuffer();
    if (type == QueryType.select) {
      if (findOne ?? false) {
        queryString.write('db.collection.findOne(');
      } else {
        queryString.write('db.collection.find(');
      }
    } else if (type == QueryType.insert) {
      queryString.write('db.collection.insert(');
    }

    final query = {};

    if (selectFields != null) {
      query['project'] = selectFields;
    }
    if (whereMap != null) {
      query.addAll(whereMap!);
    }
    if (insertValues != null) {
      query.addAll(insertValues!);
    }

    queryString.write(json.encode(query));
    queryString.write(');');

    return queryString.toString();
  }
}

class SafeQueryBuilderParameterParser {
  String parseColumn(Object column) {
    return column is RawQueryComponent
        ? column.value
        : (column as String).split(column.contains(',') ? ',' : ' ').first;
  }

  String parseSortDirection(String sortMethod) {
    return ['asc', 'desc'].contains(sortMethod.toLowerCase())
        ? sortMethod
        : 'DESC';
  }
}

class RawQueryComponent {
  String value;
  List? bindings;

  RawQueryComponent(this.value, [this.bindings]);
}
