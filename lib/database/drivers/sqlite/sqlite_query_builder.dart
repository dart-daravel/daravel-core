import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart' as daravel;
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/exceptions/query.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/exceptions/record_not_found.dart';
import 'package:daravel_core/helpers/database.dart';
import 'package:collection/collection.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  daravel.DBDriver driver;

  @override
  ORM? orm;

  late final SafeQueryBuilderParameterParser safeQueryBuilderParameterParser =
      SafeQueryBuilderParameterParser();

  final List<WhereClause> _whereList = [];

  String? _limitQuery;
  String? _orderByQuery;
  String? _groupByQuery;

  bool _resultSafe = true;
  bool _distinct = false;

  SQLiteQueryBuilder(this.driver, [this.table, this.orm]);

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

  Record? _castRecord(Record record) {
    if (orm != null) {
      return Entity.fromRecord(record, orm.runtimeType, orm!.relationships);
    }
    return record;
  }

  RecordSet _castRecordSet(RecordSet records) {
    if (orm != null) {
      records.orm = orm;
      return records;
    }
    return records;
  }

  @override
  Future<RecordSet> get() async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    final query = _buildQuery(QueryType.select);

    _reset();
    return _castRecordSet(
        await driver.select(query.query, query.bindings, orm));
  }

  @override
  Future<Record?> first() async {
    final result = await get();
    return result.isNotEmpty ? _castRecord(result.first) : null;
  }

  @override
  Future<Record> firstOrFail() async {
    final result = await first();
    if (result == null) {
      throw RecordNotFoundException();
    }
    return _castRecord(result)!;
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
      final deleted = await driver.delete(query.query, query.bindings);

      _reset();
      return deleted;
    } finally {
      driver.deleteMutex.release();
    }
  }

  @override
  QueryBuilder limit(int limit, [int? offset]) {
    _limitQuery = 'LIMIT ${offset != null ? '$offset, ' : ''}$limit';
    return this;
  }

  @override
  Future<Object?> value(String column) async {
    return (await first())![column];
  }

  @override
  Future<Record?> find(dynamic id) async {
    return await where('id', id).first();
  }

  @override
  Future<List<Object?>> pluck(String column) async {
    select(column);
    final result = await get();
    return result.map((record) => (record as SqliteRecord)[column]).toList();
  }

  @override
  Future<void> chunk(
      int size, bool? Function(RecordSet records) callback) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    RecordSet? records;
    int offset = 0;
    limit(size, offset);
    QueryStringBinding query = _buildQuery(QueryType.select);
    String sqlStatement = query.query;
    do {
      records = await driver.select(sqlStatement, query.bindings, orm);
      if (records.isEmpty || callback(_castRecordSet(records)) == false) {
        break;
      }
      offset += size;
      sqlStatement = sqlStatement.replaceFirst(
          'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
    } while (true);
    _reset();
  }

  @override
  Future<void> chunkById(
      int size, bool? Function(RecordSet records) callback) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    RecordSet? records;
    int offset = 0;
    where('id', '>', offset).limit(size, offset);
    QueryStringBinding query = _buildQuery(QueryType.select);
    String sqlStatement = query.query;
    do {
      records = await driver.select(sqlStatement, query.bindings, orm);
      if (records.isEmpty || callback(_castRecordSet(records)) == false) {
        break;
      }
      offset += size;
      sqlStatement = sqlStatement.replaceFirst(
          'LIMIT ${offset - size}, $size', 'LIMIT $offset, $size');
    } while (true);
    _reset();
  }

  @override
  QueryBuilder orderBy(String column, [String direction = 'DESC']) {
    _orderByQuery =
        'ORDER BY $column ${safeQueryBuilderParameterParser.parseSortDirection(direction)}';
    return this;
  }

  /// Build the SQL query.
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
  Future<QueryBuilder> whereAsync(Function(QueryBuilder) closure) async {
    _resultSafe = false;
    _addWhere('AND', true, false);
    await closure(this);
    _addWhere('AND', false, true);
    _resultSafe = true;
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
    return SqliteLazyRecordSetGenerator(driver, query, 50, this);
  }

  @override
  LazyRecordSetGenerator lazyById() {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    where('id', '>', 0).limit(50, 0);
    final query = _buildQuery(QueryType.select);
    _reset();
    return SqliteLazyRecordSetGenerator(driver, query, 50, this);
  }

  @override
  Future<num> avg(String column) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('AVG($column) AS avg');
    final result = await get();
    _selectColumns = List.from(backupSelectColumns);
    final avg = result.first['avg'].toString();
    return num.parse(avg == 'null' ? '0' : avg);
  }

  @override
  Future<int> count([String columns = '*']) async {
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
    final result = await get();
    _selectColumns = List.from(backupSelectColumns);
    final count = result.first['count'].toString();
    return int.parse(count == 'null' ? '0' : count);
  }

  @override
  Future<int> max(String column) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('MAX($column) AS max');
    final result = await get();
    _selectColumns = List.from(backupSelectColumns);
    final max = result.first['max'].toString();
    return int.parse(max == 'null' ? '0' : max);
  }

  @override
  Future<int> min(String column) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('MIN($column) AS min');
    final result = await get();
    _selectColumns = List.from(backupSelectColumns);
    final min = result.first['min'].toString();
    return int.parse(min == 'null' ? '0' : min);
  }

  @override
  Future<int> sum(String column) async {
    if (!_resultSafe) {
      throw QueryException('Query builder is in an illegal state.');
    }
    List<String> backupSelectColumns = List.from(_selectColumns);
    _selectColumns.clear();
    _selectColumns.add('SUM($column) AS sum');
    final result = await get();
    _selectColumns = List.from(backupSelectColumns);
    final sum = result.first['sum'].toString();
    return int.parse(sum == 'null' ? '0' : sum);
  }

  @override
  Future<bool> doesntExist() async => !await exists();

  @override
  Future<bool> exists() async {
    final queryStringBinding = _buildQuery(QueryType.select, const {}, false);
    final String query = 'SELECT EXISTS(${queryStringBinding.query});';
    final result = await driver.select(query, queryStringBinding.bindings, orm);
    return result.first[0] as int == 1;
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

class SqliteLazyRecordSetGenerator extends LazyRecordSetGenerator {
  SqliteLazyRecordSetGenerator(
      super.driver, super.selectQuery, super.bufferSize, super.queryBuilder);

  late final ConsoleLogger logger = ConsoleLogger();

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
      final result = await driver.select(query, bindings);
      if (result.isEmpty) {
        break;
      }
      yield _castRecordSet(result);
      offset += chunkSize;
      query = query.replaceFirst('LIMIT ${offset - chunkSize}, $chunkSize',
          'LIMIT $offset, $chunkSize');
    }
  }

  RecordSet _castRecordSet(RecordSet records) {
    if (queryBuilder.orm != null) {
      records.orm = queryBuilder.orm;
      return records;
    }
    return records;
  }
}
