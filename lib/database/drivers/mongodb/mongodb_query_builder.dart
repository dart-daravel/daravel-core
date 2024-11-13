import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart' as daravel;
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/query.dart';
import 'package:daravel_core/exceptions/record_not_found.dart';
import 'package:daravel_core/helpers/database.dart';
import 'package:collection/collection.dart';
import 'package:sqlite3/sqlite3.dart';

class MongoDBQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  daravel.DBDriver driver;

  late final SafeQueryBuilderParameterParser safeQueryBuilderParameterParser =
      SafeQueryBuilderParameterParser();

  final List<WhereClause> _whereList = [];

  String? _limitQuery;
  String? _orderByQuery;
  String? _groupByQuery;

  bool _resultSafe = true;
  bool _distinct = false;

  late final ConsoleLogger logger = ConsoleLogger();

  MongoDBQueryBuilder(this.driver, [this.table]);

  List<String> _selectColumns = [];
  final Map<int, List> _selectBindings = {};
  List<String>? _oldSelectColumns;

  void _reset() {
    _whereList.clear();
    _limitQuery = null;
    _orderByQuery = null;
    _oldSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
  }

  @override
  QueryBuilder select(dynamic columns) {
    assert(columns is List<String> ||
        columns is String ||
        columns is RawQueryComponent);
    if (columns is List<String>) {
      for (final column in columns) {
        _selectColumns.add(safeQueryBuilderParameterParser.parseColumn(column));
      }
    } else if (columns is String) {
      _selectColumns.add(safeQueryBuilderParameterParser.parseColumn(columns));
    } else if (columns is RawQueryComponent) {
      _selectColumns.add(safeQueryBuilderParameterParser.parseColumn(columns));
      if (columns.bindings != null) {
        _selectBindings[_selectColumns.length - 1] = columns.bindings!;
      }
    }
    return this;
  }

  @override
  RecordSet get() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    final query = _buildQuery(QueryType.select);
    _logQuery(query);
    _reset();
    return driver.select(query.query, query.bindings)!;
  }

  @override
  Record? first() {
    final result = get();
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Record firstOrFail() {
    final result = first();
    if (result == null) {
      throw RecordNotFoundException();
    }
    return result;
  }

  @override
  bool insert(Map<String, dynamic> values) {
    if (values.isEmpty) {
      throw QueryException('Values cannot be empty');
    }
    final query = _buildQuery(QueryType.insert, values);
    driver.insert(query.query, query.bindings);
    _reset();
    return true;
  }

  @override
  Future<int> insertGetId(Map<String, dynamic> values) async {
    if (values.isEmpty) {
      throw QueryException('Values cannot be empty');
    }
    final query = _buildQuery(QueryType.insert, values);
    _reset();
    return driver.insertGetId(query.query, query.bindings);
  }

  @override
  Future<int> update(Map<String, dynamic> values) async {
    if (values.isEmpty) {
      throw QueryException('Values cannot be empty');
    }
    final query = _buildQuery(QueryType.update, values);
    await driver.updateMutex.acquire();
    try {
      _logQuery(query);
      _reset();
      return driver.update(query.query, query.bindings);
    } finally {
      driver.updateMutex.release();
    }
  }

  @override
  Future<int> delete([Object? id]) async {
    if (id != null) {
      where('id', id);
    }
    final query = _buildQuery(QueryType.delete);
    await driver.deleteMutex.acquire();
    try {
      _reset();
      return driver.delete(query.query, query.bindings);
    } finally {
      driver.deleteMutex.release();
    }
  }

  _logQuery(QueryStringBinding query) {
    if (driver.logging) {
      query.getUnsafeQuery().then((query) => logger.debug(query));
    }
  }

  @override
  QueryBuilder limit(int limit, [int? offset]) {
    _limitQuery = 'LIMIT ${offset != null ? '$offset, ' : ''}$limit';
    return this;
  }

  @override
  Object? value(String column) {
    return first()?[column];
  }

  @override
  Record? find(dynamic id) {
    return where('id', id).first();
  }

  @override
  List<Object?> pluck(String column) {
    select(column);
    final result = get();
    return result.map((record) => (record as Row)[column]).toList();
  }

  @override
  void chunk(int size, bool? Function(RecordSet records) callback) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    RecordSet? records;
    int offset = 0;
    limit(size, offset);
    QueryStringBinding query = _buildQuery(QueryType.select);
    String sqlStatement = query.query;
    do {
      records = driver.select(sqlStatement, query.bindings)!;
      if (callback(records) == false) {
        break;
      }
      offset += size;
      sqlStatement = sqlStatement.replaceFirst(
          'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
    } while (records.isNotEmpty);
    _reset();
  }

  @override
  void chunkById(int size, bool? Function(RecordSet records) callback) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    RecordSet? records;
    int offset = 0;
    where('id', '>', offset).limit(size, offset);
    QueryStringBinding query = _buildQuery(QueryType.select);
    String sqlStatement = query.query;
    do {
      records = driver.select(sqlStatement, query.bindings)!;
      _logQuery(query);
      if (callback(records) == false) {
        break;
      }
      offset += size;
      sqlStatement = sqlStatement.replaceFirst(
          'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
    } while (records.isNotEmpty);
    _reset();
  }

  @override
  QueryBuilder orderBy(String column, [String direction = 'DESC']) {
    _orderByQuery =
        'ORDER BY $column ${safeQueryBuilderParameterParser.parseSortDirection(direction)}';
    return this;
  }

  /// Build the WHERE clause of the query.
  QueryStringBinding _buildQuery(QueryType type,
      [Map<String, dynamic> values = const {}, bool terminate = true]) {
    switch (type) {
      case QueryType.select:
        return _buildSelectQuery(terminate);
      case QueryType.insert:
        return _buildInsertQuery(values, terminate);
      case QueryType.update:
        return _buildUpdateQuery(values, terminate);
      case QueryType.delete:
        return _buildDeleteQuery(terminate);
    }
  }

  QueryStringBinding _buildSelectQuery([bool terminate = true]) {
    final query = StringBuffer();
    final List bindings = [];
    query.write('SELECT ');
    // We don't want DISTINCT immediately after SELECT if a COUNT(*) select column is present.
    // We'll have to apply distinct on the COUNT() column itself.
    if (_distinct &&
        _selectColumns.firstWhereOrNull(
                (e) => e.toUpperCase().startsWith('COUNT(')) ==
            null) {
      query.write('DISTINCT ');
    }
    if (_selectColumns.isEmpty) {
      query.write('*');
    } else if (_selectColumns.length == 1) {
      query.write(_selectColumns.first);
      if (_selectBindings.containsKey(0)) {
        bindings.addAll(_selectBindings[0]!);
      }
    } else {
      query.write(_selectColumns.join(', '));
      for (var i = 0; i < _selectColumns.length; i++) {
        if (_selectBindings.containsKey(i)) {
          bindings.addAll(_selectBindings[i]!);
        }
      }
    }
    query.write(' FROM $table');
    // WHERE clause.
    _writeWhereClause(query, bindings);
    // GROUP BY clause.
    if (_groupByQuery != null) {
      query.write(' $_groupByQuery');
    }
    // ORDER BY clause.
    if (_orderByQuery != null) {
      query.write(' $_orderByQuery');
    }
    // LIMIT clause.
    if (_limitQuery != null) {
      query.write(' $_limitQuery');
    }
    if (terminate) {
      query.write(';');
    }
    return QueryStringBinding(query.toString(), bindings);
  }

  void _writeWhereClause(StringBuffer query, List bindings) {
    if (_whereList.isNotEmpty) {
      query.write(' WHERE ');
      for (var i = 0; i < _whereList.length; i++) {
        final entry = _whereList[i];
        if (entry.isOpenBracket) {
          query.write('(');
          continue;
        } else if (entry.isCloseBracket) {
          query.write(')');
          continue;
        }
        if (entry.rawClause != null) {
          query.write(entry.rawClause);
          if (entry.rawBindings != null) {
            bindings.addAll(entry.rawBindings!);
          }
        } else {
          query.write("${entry.column} ${entry.operator} ?");
          bindings.add(entry.value);
        }
        if (i < _whereList.length - 1 && !_whereList[i + 1].isCloseBracket) {
          query.write(' ${entry.concatenator} ');
        }
      }
    }
  }

  QueryStringBinding _buildInsertQuery(Map<String, dynamic> values,
      [bool terminate = true]) {
    final query = StringBuffer();
    final List bindings = [];
    query.write(
        'INSERT INTO $table (${values.keys.join(', ')}) VALUES (${values.values.map((e) {
      bindings.add(e);
      return '?';
    }).join(', ')})');
    if (terminate) {
      query.write(';');
    }
    return QueryStringBinding(query.toString(), bindings);
  }

  QueryStringBinding _buildUpdateQuery(Map<String, dynamic> values,
      [bool terminate = true]) {
    final List bindings = [];
    final query = StringBuffer();
    query.write('UPDATE $table SET ');
    query.write(values.keys.map((e) {
      bindings.add(values[e]);
      return '$e = ?';
    }).join(', '));
    _writeWhereClause(query, bindings);
    if (terminate) {
      query.write(';');
    }
    return QueryStringBinding(query.toString(), bindings);
  }

  QueryStringBinding _buildDeleteQuery([bool terminate = true]) {
    final query = StringBuffer();
    final List bindings = [];
    query.write('DELETE FROM $table');
    _writeWhereClause(query, bindings);
    if (terminate) {
      query.write(';');
    }
    return QueryStringBinding(query.toString(), bindings);
  }

  void _addWhere(
      String logicConcatenator, bool isOpenBracket, bool isCloseBracket,
      [String? column,
      dynamic operatorOrValue,
      dynamic value,
      String? rawWhere,
      List<dynamic>? rawBindings]) {
    // Add logic concatenator to the last entry.
    if (_whereList.isNotEmpty) {
      _whereList[_whereList.length - 1].concatenator = logicConcatenator;
    }
    // Raw where clause.
    if (rawWhere != null) {
      _whereList.add(WhereClause(
        isOpenBracket: isOpenBracket,
        isCloseBracket: isCloseBracket,
        rawClause: rawWhere,
        rawBindings: rawBindings,
      ));
      return;
    }
    // Add new entry.
    if (operatorOrValue is String && isSqlOperator(operatorOrValue)) {
      _whereList.add(
        WhereClause(
          isOpenBracket: isOpenBracket,
          column: column,
          operator: operatorOrValue,
          value: value,
          isCloseBracket: isCloseBracket,
        ),
      );
    } else {
      _whereList.add(
        WhereClause(
          isOpenBracket: isOpenBracket,
          column: column,
          operator: '=',
          value: operatorOrValue,
          isCloseBracket: isCloseBracket,
        ),
      );
    }
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
  QueryBuilder orWhere(dynamic column, [operatorOrValue, value]) {
    if (column is Function) {
      _resultSafe = false;
      _addWhere('OR', true, false);
      column(this);
      _addWhere('OR', false, true);
      _resultSafe = true;
      return this;
    }
    _addWhere('OR', false, false, column, operatorOrValue, value);
    return this;
  }

  @override
  LazyRecordSetGenerator lazy() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    limit(50, 0);
    final query = _buildQuery(QueryType.select);
    _reset();
    return MongoDBLazyRecordSetGenerator(driver, query, 50);
  }

  @override
  LazyRecordSetGenerator lazyById() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    where('id', '>', 0).limit(50, 0);
    final query = _buildQuery(QueryType.select);
    _reset();
    return MongoDBLazyRecordSetGenerator(driver, query, 50);
  }

  @override
  num avg(String column) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('AVG($column) AS avg');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final avg = result.first['avg'].toString();
    return num.parse(avg == 'null' ? '0' : avg);
  }

  @override
  int count([String columns = '*']) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    if (_distinct && (columns.contains(',') || columns.contains(' '))) {
      throw QueryException('Cannot use COUNT(DISTINCT) with multiple columns.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns
        .add('COUNT(${_distinct ? 'DISTINCT ' : ''}$columns) AS count');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final count = result.first['count'].toString();
    return int.parse(count == 'null' ? '0' : count);
  }

  @override
  int max(String column) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('MAX($column) AS max');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final max = result.first['max'].toString();
    return int.parse(max == 'null' ? '0' : max);
  }

  @override
  int min(String column) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('MIN($column) AS min');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final min = result.first['min'].toString();
    return int.parse(min == 'null' ? '0' : min);
  }

  @override
  int sum(String column) {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('SUM($column) AS sum');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final sum = result.first['sum'].toString();
    return int.parse(sum == 'null' ? '0' : sum);
  }

  @override
  bool doesntExist() => !exists();

  @override
  bool exists() {
    final queryStringBinding = _buildQuery(QueryType.select, const {}, false);
    final String query = 'SELECT EXISTS(${queryStringBinding.query});';
    final result = driver.select(query, queryStringBinding.bindings);
    return result!.first[0] as int == 1;
  }

  @override
  QueryBuilder distinct() {
    _distinct = true;
    return this;
  }

  @override
  QueryBuilder addSelect(String column) {
    if (_selectColumns.isEmpty && _oldSelectColumns != null) {
      _selectColumns = List.from(_oldSelectColumns!);
      _oldSelectColumns = null;
    }
    _selectColumns.add(safeQueryBuilderParameterParser.parseColumn(column));
    return this;
  }

  @override
  QueryBuilder selectRaw(String rawSelect, [List bindings = const []]) {
    select(RawQueryComponent(rawSelect, bindings));
    return this;
  }

  @override
  QueryBuilder whereRaw(String rawWhere, [List<dynamic> bindings = const []]) {
    _addWhere('AND', false, false, null, null, null, rawWhere, bindings);
    return this;
  }

  @override
  QueryBuilder orWhereRaw(String rawWhere,
      [List<dynamic> bindings = const []]) {
    _addWhere('OR', false, false, null, null, null, rawWhere, bindings);
    return this;
  }

  @override
  QueryBuilder groupBy(String column) {
    _groupByQuery = 'GROUP BY $column';
    return this;
  }
}

class MongoDBLazyRecordSetGenerator extends LazyRecordSetGenerator {
  MongoDBLazyRecordSetGenerator(
      super.driver, super.selectQuery, super.bufferSize);

  Stream<RecordSet>? recordSetStream;

  @override
  Future<void> each(bool? Function(Record record) callback) async {
    outer:
    await for (final chunk in _chunkStreamer(
        selectQuery.query, selectQuery.bindings, bufferSize)) {
      for (var x = 0; x < chunk.length; x++) {
        if (callback(chunk[x]) == false) {
          break outer;
        }
      }
    }
  }

  Stream<RecordSet> _chunkStreamer(
      String query, List bindings, int chunkSize) async* {
    int offset = 0;
    while (true) {
      final result = driver.select(query, bindings)!;
      if (result.isEmpty) {
        break;
      }
      yield result;
      offset += chunkSize;
      query = query.replaceFirst('LIMIT ${offset - chunkSize}, $chunkSize',
          'LIMIT $offset, $chunkSize');
    }
  }
}
