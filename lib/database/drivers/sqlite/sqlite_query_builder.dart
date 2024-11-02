import 'package:daravel_core/database/concerns/db_driver.dart' as daravel;
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/query.dart';
import 'package:daravel_core/exceptions/record_not_found.dart';
import 'package:daravel_core/helpers/database.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  daravel.DBDriver driver;

  final List<WhereClause> _whereList = [];

  String? _limitQuery;
  String? _orderByQuery;
  int? _lastInsertId;

  bool _resultSafe = true;

  SQLiteQueryBuilder(this.driver, [this.table]);

  List<String> _selectColumns = [];

  void _reset() {
    _whereList.clear();
    _limitQuery = null;
    _orderByQuery = null;
    _selectColumns.clear();
  }

  @override
  QueryBuilder select(dynamic columns) {
    assert(columns is List<String> || columns is String);
    if (columns is List<String>) {
      for (final column in columns) {
        _selectColumns.add(_parseSelectColumn(column));
      }
    } else if (columns is String) {
      _selectColumns.add(_parseSelectColumn(columns));
    }
    return this;
  }

  String _parseSelectColumn(String column) => column.startsWith('[=]')
      ? column.substring(3)
      : column; // TODO: Improve this to clean up input.

  @override
  RecordSet get() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    final query = _buildQuery(QueryType.select);
    _reset();
    return driver.select(query)!;
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
  Future<int> insert(Map<String, dynamic> values) async {
    if (values.isEmpty) {
      throw QueryException('Values cannot be empty');
    }
    final query = _buildQuery(QueryType.insert, values);
    await driver.insertMutex.acquire();
    try {
      driver.insert(query, values.values.toList());
      _lastInsertId = driver.lastInsertId!;
    } finally {
      driver.insertMutex.release();
    }
    _reset();
    return _lastInsertId!;
  }

  @override
  Future<int> update(Map<String, dynamic> values) async {
    if (values.isEmpty) {
      throw QueryException('Values cannot be empty');
    }
    final query = _buildQuery(QueryType.update, values);
    late final int affectedRows;
    await driver.updateMutex.acquire();
    try {
      print(query);
      driver.update(query, values.values.toList());
      affectedRows = driver.affectedRows!;
    } finally {
      driver.updateMutex.release();
    }
    _reset();
    return affectedRows;
  }

  @override
  Future<int> delete([Object? id]) async {
    if (id != null) {
      where('id', id);
    }
    final query = _buildQuery(QueryType.delete);
    late final int affectedRows;
    await driver.deleteMutex.acquire();
    try {
      driver.delete(query);
      affectedRows = driver.affectedRows!;
    } finally {
      driver.deleteMutex.release();
    }
    _reset();
    return affectedRows;
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
    String query = _buildQuery(QueryType.select);
    do {
      records = driver.select(query)!;
      if (callback(records) == false) {
        break;
      }
      offset += size;
      query = query.replaceFirst(
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
    String query = _buildQuery(QueryType.select);
    do {
      records = driver.select(query)!;
      if (callback(records) == false) {
        break;
      }
      offset += size;
      query = query.replaceFirst(
          'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
    } while (records.isNotEmpty);
    _reset();
  }

  @override
  QueryBuilder orderBy(String column, [String direction = 'ASC']) {
    _orderByQuery = 'ORDER BY $column $direction';
    return this;
  }

  String _buildQuery(QueryType type,
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

  String _buildSelectQuery([bool terminate = true]) {
    final query = StringBuffer();
    query.write('SELECT ');
    if (_selectColumns.isEmpty) {
      query.write('*');
    } else if (_selectColumns.length == 1) {
      query.write(_selectColumns.first);
    } else {
      query.write(_selectColumns.join(', '));
    }
    query.write(' FROM $table');
    // WHERE clause.
    _writeWhereClause(query);
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
    return query.toString();
  }

  void _writeWhereClause(StringBuffer query) {
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
        query.write('${entry.column} ${entry.operator} ${entry.value}');
        if (i < _whereList.length - 1 && !_whereList[i + 1].isCloseBracket) {
          query.write(' ${entry.concatenator} ');
        }
      }
    }
  }

  String _buildInsertQuery(Map<String, dynamic> values,
      [bool terminate = true]) {
    final query = StringBuffer();
    query.write(
        'INSERT INTO $table (${values.keys.join(', ')}) VALUES (${values.keys.map((_) => '?').join(', ')})');
    if (terminate) {
      query.write(';');
    }
    return query.toString();
  }

  String _buildUpdateQuery(Map<String, dynamic> values,
      [bool terminate = true]) {
    final query = StringBuffer();
    query.write('UPDATE $table SET ');
    query.write(values.keys.map((key) => '$key = ?').join(', '));
    _writeWhereClause(query);
    if (terminate) {
      query.write(';');
    }
    return query.toString();
  }

  String _buildDeleteQuery([bool terminate = true]) {
    final query = StringBuffer();
    query.write('DELETE FROM $table');
    _writeWhereClause(query);
    if (terminate) {
      query.write(';');
    }
    return query.toString();
  }

  void _addWhere(
      String logicConcatenator, bool isOpenBracket, bool isCloseBracket,
      [String? column, dynamic operatorOrValue, dynamic value]) {
    // Add logic concatenator to the last entry.
    if (_whereList.isNotEmpty) {
      _whereList[_whereList.length - 1].concatenator = logicConcatenator;
    }
    // Add new entry.
    if (operatorOrValue is String && isSqlOperator(operatorOrValue)) {
      _whereList.add(
        WhereClause(
          isOpenBracket: isOpenBracket,
          column: column,
          operator: operatorOrValue,
          value: prepareSqlValue(value),
          isCloseBracket: isCloseBracket,
        ),
      );
    } else {
      _whereList.add(
        WhereClause(
          isOpenBracket: isOpenBracket,
          column: column,
          operator: '=',
          value: prepareSqlValue(operatorOrValue),
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
    return SqliteLazyRecordSetGenerator(driver, query, 50);
  }

  @override
  LazyRecordSetGenerator lazyById() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    where('id', '>', 0).limit(50, 0);
    final query = _buildQuery(QueryType.select);
    _reset();
    return SqliteLazyRecordSetGenerator(driver, query, 50);
  }

  @override
  num avg(String column) {
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
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('COUNT($columns) AS count');
    final result = get();
    _selectColumns = List.from(backupSelectColumns);
    final count = result.first['count'].toString();
    return int.parse(count == 'null' ? '0' : count);
  }

  @override
  int max(String column) {
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
    final String query =
        'SELECT EXISTS(${_buildQuery(QueryType.select, const {}, false)});';
    final result = driver.select(query);
    return result!.first[0] as int == 1;
  }
}

class SqliteLazyRecordSetGenerator extends LazyRecordSetGenerator {
  SqliteLazyRecordSetGenerator(
      super.driver, super.selectQuery, super.bufferSize);

  Stream<RecordSet>? recordSetStream;

  @override
  Future<void> each(bool? Function(Record record) callback) async {
    outer:
    await for (final chunk in _chunkStreamer(selectQuery, bufferSize)) {
      for (var x = 0; x < chunk.length; x++) {
        if (callback(chunk[x]) == false) {
          break outer;
        }
      }
    }
  }

  Stream<RecordSet> _chunkStreamer(String query, int chunkSize) async* {
    int offset = 0;
    while (true) {
      final result = driver.select(query)!;
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
