import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/orm/orm.dart';

import 'package:daravel_core/exceptions/query.dart';
import 'package:daravel_core/helpers/database.dart';

class MongoDBQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  DBDriver driver;

  final List<String> _selectColumns = [];
  final Map<String, Object> _whereMap = {};

  final List<Map<String, Object>> _targetWhereMaps = [];

  bool _resultSafe = true;

  late final ConsoleLogger logger = ConsoleLogger();

  @override
  ORM? orm;

  MongoDBQueryBuilder(this.driver, [this.table]);

  void _reset() {
    _targetWhereMaps.clear();
    _whereMap.clear();
    // _oldSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
  }

  @override
  QueryBuilder select(dynamic columns) {
    assert(columns is List<String> || columns is String);
    if (columns is List<String>) {
      for (final column in columns) {
        _selectColumns.add(column);
      }
    } else if (columns is String) {
      _selectColumns.add(columns);
    }
    return this;
  }

  @override
  Future<RecordSet> get() async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    final query = _buildQuery(QueryType.select);
    _reset();
    return await driver.select(table ?? '', query);
  }

  /// Build the WHERE clause of the query.
  NoSqlQuery _buildQuery(QueryType type,
      [Map<String, dynamic> values = const {}]) {
    switch (type) {
      case QueryType.select:
        return _buildSelectQuery();
      case QueryType.insert:
        return _buildInsertQuery(values);
      case QueryType.update:
        return _buildUpdateQuery(values);
      case QueryType.delete:
        return _buildDeleteQuery();
    }
  }

  NoSqlQuery _buildSelectQuery() {
    final query = NoSqlQuery(
      selectFields: _selectColumns,
      whereMap: _whereMap.isNotEmpty ? _whereMap : null,
    );
    return query;
  }

  NoSqlQuery _buildInsertQuery(Map<String, dynamic> values) {
    final query = NoSqlQuery(
      type: QueryType.insert,
      insertValues: values,
    );
    return query;
  }

  NoSqlQuery _buildUpdateQuery(Map<String, dynamic> values) {
    final query = NoSqlQuery(
      type: QueryType.update,
      whereMap: _whereMap.isNotEmpty ? _whereMap : null,
      updateValues: values,
    );
    return query;
  }

  NoSqlQuery _buildDeleteQuery() {
    final query = NoSqlQuery(
      type: QueryType.delete,
      whereMap: _whereMap.isNotEmpty ? _whereMap : null,
    );
    return query;
  }

  void _addWhere(
    String logicConcatenator,
    bool isOpenBracket,
    bool isCloseBracket, [
    String? column,
    dynamic operatorOrValue,
    dynamic value,
  ]) {
    if (_targetWhereMaps.isEmpty) {
      _targetWhereMaps.add(_whereMap);
    }
    if (isOpenBracket) {
      _targetWhereMaps.add(_expandWhereMapWithOpOperand(logicConcatenator)!);
    } else if (isCloseBracket) {
      _targetWhereMaps.removeLast();
    } else if (logicConcatenator != 'AND') {
      if (!_containsMongoDBConcatenators(_targetWhereMaps.last.keys.toList())) {
        _expandWhereMapWithOpOperand(
          logicConcatenator,
          _getMongoQueryOpOperand(
              column!,
              isSqlOperator(operatorOrValue) ? operatorOrValue : '=',
              !isSqlOperator(operatorOrValue) ? operatorOrValue : value),
        );
      } else {
        (_targetWhereMaps.last[_sqlToBsonConcatenator(logicConcatenator)]
                as List)
            .add(_getMongoQueryOpOperand(
                column!,
                isSqlOperator(operatorOrValue) ? operatorOrValue : '=',
                !isSqlOperator(operatorOrValue) ? operatorOrValue : value));
      }
    } else {
      if (!_containsMongoDBConcatenators(_targetWhereMaps.last.keys.toList())) {
        _targetWhereMaps.last[column!] = _getMongoQueryOpOperand(
            null,
            isSqlOperator(operatorOrValue) ? operatorOrValue : '=',
            !isSqlOperator(operatorOrValue) ? operatorOrValue : value);
      } else if (_targetWhereMaps.last
          .containsKey(_sqlToBsonConcatenator(logicConcatenator))) {
        (_targetWhereMaps.last[_sqlToBsonConcatenator(logicConcatenator)]
                as List)
            .add(_getMongoQueryOpOperand(
                column!,
                isSqlOperator(operatorOrValue) ? operatorOrValue : '=',
                !isSqlOperator(operatorOrValue) ? operatorOrValue : value));
      } else {
        _targetWhereMaps.last[_sqlToBsonConcatenator(logicConcatenator)] = [
          _getMongoQueryOpOperand(
              column!,
              isSqlOperator(operatorOrValue) ? operatorOrValue : '=',
              !isSqlOperator(operatorOrValue) ? operatorOrValue : value)
        ];
      }
    }
  }

  Map<String, Object>? _expandWhereMapWithOpOperand(String concatenator,
      [Map<String, Object>? opOperand]) {
    final andMap = Map.from(_targetWhereMaps.last);
    _targetWhereMaps.clear();
    _targetWhereMaps.last[_sqlToBsonConcatenator('AND')] = andMap;
    if (opOperand != null) {
      _targetWhereMaps.last[_sqlToBsonConcatenator(concatenator)] = [
        opOperand,
      ];
    } else {
      final Map<String, Object> newMap = {};
      if (_targetWhereMaps.last
          .containsKey(_sqlToBsonConcatenator(concatenator))) {
        (_targetWhereMaps.last[_sqlToBsonConcatenator(concatenator)] as List)
            .add(newMap);
      } else {
        _targetWhereMaps.last[_sqlToBsonConcatenator(concatenator)] = [newMap];
      }
      return newMap;
    }
    return null;
  }

  Map<String, Object> _getMongoQueryOpOperand(
      String? column, String operator, String value) {
    switch (operator) {
      case '>':
        return column != null
            ? {
                column: {'\$gt': value}
              }
            : {'\$gt': value};
      case '<':
        return column != null
            ? {
                column: {'\$lt': value}
              }
            : {'\$lt': value};
      case '!=':
      case '<>':
        return column != null
            ? {
                column: {'\$ne': value}
              }
            : {'\$ne': value};
      case '=':
      default:
        return {column!: value};
    }
  }

  bool _containsMongoDBConcatenators(List<String> keys) {
    for (final key in keys) {
      if (['\$or', '\$and'].contains(key)) {
        return true;
      }
    }
    return false;
  }

  String _sqlToBsonConcatenator(String concatenator) {
    switch (concatenator) {
      case 'AND':
        return '\$and';
      case 'OR':
        return '\$or';
      case 'NOT':
        return '\$not';
      case 'NOR':
        return '\$nor';
      default:
        return '\$and';
    }
  }

  @override
  QueryBuilder addSelect(String column) {
    // TODO: implement addSelect
    throw UnimplementedError();
  }

  @override
  Future<num> avg(String column) {
    // TODO: implement avg
    throw UnimplementedError();
  }

  @override
  Future<void> chunk(int size, bool? Function(RecordSet records) callback) {
    // TODO: implement chunk
    throw UnimplementedError();
  }

  @override
  Future<void> chunkById(int size, bool? Function(RecordSet records) callback) {
    // TODO: implement chunkById
    throw UnimplementedError();
  }

  @override
  Future<int> count([String columns = '*']) {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  Future<int> delete([Object? id]) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  QueryBuilder distinct() {
    // TODO: implement distinct
    throw UnimplementedError();
  }

  @override
  Future<bool> doesntExist() {
    // TODO: implement doesntExist
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Future<Record?> find(id) {
    // TODO: implement find
    throw UnimplementedError();
  }

  @override
  Future<Record?> first() async {
    final result = await get();
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<Record> firstOrFail() {
    // TODO: implement firstOrFail
    throw UnimplementedError();
  }

  @override
  QueryBuilder groupBy(String column) {
    // TODO: implement groupBy
    throw UnimplementedError();
  }

  @override
  bool insert(Map<String, dynamic> values) {
    // TODO: implement insert
    throw UnimplementedError();
  }

  @override
  Future<int> insertGetId(Map<String, dynamic> values) {
    // TODO: implement insertGetId
    throw UnimplementedError();
  }

  @override
  LazyRecordSetGenerator lazy() {
    // TODO: implement lazy
    throw UnimplementedError();
  }

  @override
  LazyRecordSetGenerator lazyById() {
    // TODO: implement lazyById
    throw UnimplementedError();
  }

  @override
  QueryBuilder limit(int limit, [int? offset]) {
    // TODO: implement limit
    throw UnimplementedError();
  }

  @override
  Future<int> max(String column) {
    // TODO: implement max
    throw UnimplementedError();
  }

  @override
  Future<int> min(String column) {
    // TODO: implement min
    throw UnimplementedError();
  }

  @override
  QueryBuilder orWhere(column, [operatorOrValue, value]) {
    // TODO: implement orWhere
    throw UnimplementedError();
  }

  @override
  QueryBuilder orWhereRaw(String rawWhere, [List bindings = const []]) {
    throw UnimplementedError();
  }

  @override
  QueryBuilder orderBy(String column, [String direction = 'ASC']) {
    // TODO: implement orderBy
    throw UnimplementedError();
  }

  @override
  Future<List<Object?>> pluck(String column) {
    // TODO: implement pluck
    throw UnimplementedError();
  }

  @override
  QueryBuilder selectRaw(String rawSelect, [List bindings = const []]) {
    throw UnimplementedError('selectRaw not supported for MongoDB driver.');
  }

  @override
  Future<int> sum(String column) {
    throw UnimplementedError();
  }

  @override
  Future<int> update(Map<String, dynamic> values) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<Object?> value(String column) {
    // TODO: implement value
    throw UnimplementedError();
  }

  @override
  QueryBuilder where(dynamic column, [operatorOrValue, value]) {
    if (column is Function) {
      _resultSafe = false;
      _addWhere('AND', true, false);
      column(this);
      _addWhere('AND', false, true);
      _resultSafe = true;
      return this;
    }
    _addWhere('AND', false, false, column, operatorOrValue, value);
    return this;
  }

  @override
  QueryBuilder whereRaw(String rawWhere, [List bindings = const []]) {
    throw UnimplementedError();
  }

//   @override
//   Future<Record> firstOrFail() async {
//     final result = first();
//     if (result == null) {
//       throw RecordNotFoundException();
//     }
//     return result;
//   }

//   @override
//   bool insert(Map<String, dynamic> values) {
//     if (values.isEmpty) {
//       throw QueryException('Values cannot be empty');
//     }
//     final query = _buildQuery(QueryType.insert, values);
//     driver.insert(query.query, query.bindings);
//     _reset();
//     return true;
//   }

//   @override
//   Future<int> insertGetId(Map<String, dynamic> values) async {
//     if (values.isEmpty) {
//       throw QueryException('Values cannot be empty');
//     }
//     final query = _buildQuery(QueryType.insert, values);
//     _reset();
//     return driver.insertGetId(query.query, query.bindings);
//   }

//   @override
//   Future<int> update(Map<String, dynamic> values) async {
//     if (values.isEmpty) {
//       throw QueryException('Values cannot be empty');
//     }
//     final query = _buildQuery(QueryType.update, values);
//     await driver.updateMutex.acquire();
//     try {
//       _reset();
//       return driver.update(query.query, query.bindings);
//     } finally {
//       driver.updateMutex.release();
//     }
//   }

//   @override
//   Future<int> delete([Object? id]) async {
//     if (id != null) {
//       where('id', id);
//     }
//     final query = _buildQuery(QueryType.delete);
//     await driver.deleteMutex.acquire();
//     try {
//       _reset();
//       return driver.delete(query.query, query.bindings);
//     } finally {
//       driver.deleteMutex.release();
//     }
//   }

  @override
  Future<QueryBuilder> whereAsync(Function(QueryBuilder p1) where) {
    // TODO: implement whereAsync
    throw UnimplementedError();
  }

//   @override
//   QueryBuilder limit(int limit, [int? offset]) {
//     _limitQuery = 'LIMIT ${offset != null ? '$offset, ' : ''}$limit';
//     return this;
//   }

//   @override
//   Object? value(String column) {
//     return first()?[column];
//   }

//   @override
//   Record? find(dynamic id) {
//     return where('id', id).first();
//   }

//   @override
//   List<Object?> pluck(String column) {
//     select(column);
//     final result = get();
//     return result.map((record) => (record as Row)[column]).toList();
//   }

//   @override
//   void chunk(int size, bool? Function(RecordSet records) callback) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     RecordSet? records;
//     int offset = 0;
//     limit(size, offset);
//     QueryStringBinding query = _buildQuery(QueryType.select);
//     String sqlStatement = query.query;
//     do {
//       records = driver.select(sqlStatement, query.bindings)!;
//       if (callback(records) == false) {
//         break;
//       }
//       offset += size;
//       sqlStatement = sqlStatement.replaceFirst(
//           'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
//     } while (records.isNotEmpty);
//     _reset();
//   }

//   @override
//   void chunkById(int size, bool? Function(RecordSet records) callback) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     RecordSet? records;
//     int offset = 0;
//     where('id', '>', offset).limit(size, offset);
//     QueryStringBinding query = _buildQuery(QueryType.select);
//     String sqlStatement = query.query;
//     do {
//       records = driver.select(sqlStatement, query.bindings)!;
//       if (callback(records) == false) {
//         break;
//       }
//       offset += size;
//       sqlStatement = sqlStatement.replaceFirst(
//           'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
//     } while (records.isNotEmpty);
//     _reset();
//   }

//   @override
//   QueryBuilder orderBy(String column, [String direction = 'DESC']) {
//     _orderByQuery =
//         'ORDER BY $column ${safeQueryBuilderParameterParser.parseSortDirection(direction)}';
//     return this;
//   }

//   @override
//   QueryBuilder orWhere(dynamic column, [operatorOrValue, value]) {
//     if (column is Function) {
//       _resultSafe = false;
//       _addWhere('OR', true, false);
//       column(this);
//       _addWhere('OR', false, true);
//       _resultSafe = true;
//       return this;
//     }
//     _addWhere('OR', false, false, column, operatorOrValue, value);
//     return this;
//   }

//   @override
//   LazyRecordSetGenerator lazy() {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     limit(50, 0);
//     final query = _buildQuery(QueryType.select);
//     _reset();
//     return MongoDBLazyRecordSetGenerator(driver, query, 50);
//   }

//   @override
//   LazyRecordSetGenerator lazyById() {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     where('id', '>', 0).limit(50, 0);
//     final query = _buildQuery(QueryType.select);
//     _reset();
//     return MongoDBLazyRecordSetGenerator(driver, query, 50);
//   }

//   @override
//   num avg(String column) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     List<String> backupSelectColumns = List.from(_selectColumns);
//     _selectColumns.clear();
//     _selectColumns.add('AVG($column) AS avg');
//     final result = get();
//     _selectColumns = List.from(backupSelectColumns);
//     final avg = result.first['avg'].toString();
//     return num.parse(avg == 'null' ? '0' : avg);
//   }

//   @override
//   int count([String columns = '*']) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     if (_distinct && (columns.contains(',') || columns.contains(' '))) {
//       throw QueryException('Cannot use COUNT(DISTINCT) with multiple columns.');
//     }
//     List<String> backupSelectColumns = List.from(_selectColumns);
//     _selectColumns.clear();
//     _selectColumns
//         .add('COUNT(${_distinct ? 'DISTINCT ' : ''}$columns) AS count');
//     final result = get();
//     _selectColumns = List.from(backupSelectColumns);
//     final count = result.first['count'].toString();
//     return int.parse(count == 'null' ? '0' : count);
//   }

//   @override
//   int max(String column) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     List<String> backupSelectColumns = List.from(_selectColumns);
//     _selectColumns.clear();
//     _selectColumns.add('MAX($column) AS max');
//     final result = get();
//     _selectColumns = List.from(backupSelectColumns);
//     final max = result.first['max'].toString();
//     return int.parse(max == 'null' ? '0' : max);
//   }

//   @override
//   int min(String column) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     List<String> backupSelectColumns = List.from(_selectColumns);
//     _selectColumns.clear();
//     _selectColumns.add('MIN($column) AS min');
//     final result = get();
//     _selectColumns = List.from(backupSelectColumns);
//     final min = result.first['min'].toString();
//     return int.parse(min == 'null' ? '0' : min);
//   }

//   @override
//   int sum(String column) {
//     if (!_resultSafe) {
//       throw QueryException('Query builder is in an illegal state.');
//     }
//     List<String> backupSelectColumns = List.from(_selectColumns);
//     _selectColumns.clear();
//     _selectColumns.add('SUM($column) AS sum');
//     final result = get();
//     _selectColumns = List.from(backupSelectColumns);
//     final sum = result.first['sum'].toString();
//     return int.parse(sum == 'null' ? '0' : sum);
//   }

//   @override
//   bool doesntExist() => !exists();

//   @override
//   bool exists() {
//     final queryStringBinding = _buildQuery(QueryType.select, const {}, false);
//     final String query = 'SELECT EXISTS(${queryStringBinding.query});';
//     final result = driver.select(query, queryStringBinding.bindings);
//     return result!.first[0] as int == 1;
//   }

//   @override
//   QueryBuilder distinct() {
//     _distinct = true;
//     return this;
//   }

//   @override
//   QueryBuilder addSelect(String column) {
//     if (_selectColumns.isEmpty && _oldSelectColumns != null) {
//       _selectColumns = List.from(_oldSelectColumns!);
//       _oldSelectColumns = null;
//     }
//     _selectColumns.add(safeQueryBuilderParameterParser.parseColumn(column));
//     return this;
//   }

//   @override
//   QueryBuilder selectRaw(String rawSelect, [List bindings = const []]) {
//     select(RawQueryComponent(rawSelect, bindings));
//     return this;
//   }

//   @override
//   QueryBuilder whereRaw(String rawWhere, [List<dynamic> bindings = const []]) {
//     _addWhere('AND', false, false, null, null, null, rawWhere, bindings);
//     return this;
//   }

//   @override
//   QueryBuilder orWhereRaw(String rawWhere,
//       [List<dynamic> bindings = const []]) {
//     _addWhere('OR', false, false, null, null, null, rawWhere, bindings);
//     return this;
//   }

//   @override
//   QueryBuilder groupBy(String column) {
//     _groupByQuery = 'GROUP BY $column';
//     return this;
//   }

//   @override
//   ORM? orm;
// }

// class MongoDBLazyRecordSetGenerator extends LazyRecordSetGenerator {
//   MongoDBLazyRecordSetGenerator(
//       super.driver, super.selectQuery, super.bufferSize);

//   Stream<RecordSet>? recordSetStream;

//   @override
//   Future<void> each(bool? Function(Record record) callback) async {
//     outer:
//     await for (final chunk in _chunkStreamer(
//         selectQuery.query, selectQuery.bindings, bufferSize)) {
//       for (var x = 0; x < chunk.length; x++) {
//         if (callback(chunk[x]) == false) {
//           break outer;
//         }
//       }
//     }
//   }

//   Stream<RecordSet> _chunkStreamer(
//       String query, List bindings, int chunkSize) async* {
//     int offset = 0;
//     while (true) {
//       final result = driver.select(query, bindings)!;
//       if (result.isEmpty) {
//         break;
//       }
//       yield result;
//       offset += chunkSize;
//       query = query.replaceFirst('LIMIT ${offset - chunkSize}, $chunkSize',
//           'LIMIT $offset, $chunkSize');
//     }
//   }
}
