import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/exceptions/record_not_found.dart';
import 'package:daravel_core/helpers/database.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  DBDriver driver;

  final List<WhereClause> _whereList = [];

  String? _limitQuery;
  String? _orderByQuery;

  SQLiteQueryBuilder(this.driver, [this.table]);

  final List<String> _selectColumns = [];

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
    late final query = _buildQuery(QueryType.select);
    print(query); // TODO: Remove this.
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
    return result.map((record) => record[column]).toList();
  }

  @override
  void chunk(int size, bool? Function(RecordSet records) callback) {
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
      print("+++ $query");
    } while (records.isNotEmpty);
    _reset();
  }

  @override
  QueryBuilder orderBy(String column, [String direction = 'ASC']) {
    _orderByQuery = 'ORDER BY $column $direction';
    return this;
  }

  String _buildQuery(QueryType type) {
    switch (type) {
      case QueryType.select:
        return _buildSelectQuery();
      case QueryType.insert:
        return _buildInsertQuery();
      case QueryType.update:
        return _buildUpdateQuery();
      case QueryType.delete:
        return _buildDeleteQuery();
    }
  }

  String _buildSelectQuery() {
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
    if (_whereList.isNotEmpty) {
      query.write(' WHERE ');
      for (var i = 0; i < _whereList.length; i++) {
        final entry = _whereList[i];
        _writeWhereClause(query, entry, i);
      }
    }
    // ORDER BY clause.
    if (_orderByQuery != null) {
      query.write(' $_orderByQuery');
    }
    // LIMIT clause.
    if (_limitQuery != null) {
      query.write(' $_limitQuery');
    }
    query.write(';');
    return query.toString();
  }

  void _writeWhereClause(
      StringBuffer query, WhereClause whereClause, int listIndex) {
    query.write(
        '${whereClause.column} ${whereClause.operator} ${whereClause.value}');
    if (listIndex < _whereList.length - 1) {
      query.write(' ${whereClause.concatenator} ');
    }
  }

  String _buildInsertQuery() {
    final query = StringBuffer();
    query.write('INSERT INTO $table');
    return query.toString();
  }

  String _buildUpdateQuery() {
    final query = StringBuffer();
    query.write('UPDATE $table');
    return query.toString();
  }

  String _buildDeleteQuery() {
    final query = StringBuffer();
    query.write('DELETE FROM $table');
    return query.toString();
  }

  void _addWhere(
      String logicConcatenator, String column, dynamic operatorOrValue,
      [dynamic value]) {
    // Add logic concatenator to the last entry.
    if (_whereList.isNotEmpty) {
      _whereList[_whereList.length - 1].concatenator = logicConcatenator;
    }
    // Add new entry.
    if (operatorOrValue is String && isSqlOperator(operatorOrValue)) {
      _whereList.add(
        WhereClause(
          column: column,
          operator: operatorOrValue,
          value: prepareSqlValue(value),
        ),
      );
    } else {
      _whereList.add(
        WhereClause(
          column: column,
          operator: '=',
          value: prepareSqlValue(operatorOrValue),
        ),
      );
    }
  }

  @override
  QueryBuilder where(dynamic column, operatorOrValue, [value]) {
    if (column is Function) {}
    _addWhere('AND', column, operatorOrValue, value);
    return this;
  }

  @override
  QueryBuilder orWhere(String column, operatorOrValue, [value]) {
    _addWhere('OR', column, operatorOrValue, value);
    return this;
  }
}
