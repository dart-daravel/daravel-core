import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:daravel_core/helpers/database.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  DBDriver driver;

  Map<String, dynamic> _insertMap = {};
  Map<String, List<String>> _whereMap = {};

  String? _limitQuery;

  SQLiteQueryBuilder(this.driver, [this.table]);

  final List<String> _selectColumns = [];

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
  QueryResult get() {
    late final query = _buildQuery(QueryType.select);
    return driver.select(query)!;
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
    // LIMIT clause.
    query.write(' FROM $table');
    if (_limitQuery != null) {
      query.write(' $_limitQuery');
    }
    // WHERE clause.
    if (_whereMap.isNotEmpty) {
      query.write(' WHERE ');
      final whereList = _whereMap.entries.toList();
      for (var i = 0; i < whereList.length; i++) {
        final entry = whereList[i];
        query.write('${entry.key} ${entry.value[0]} ${entry.value[1]}');
        if (i < whereList.length - 1) {
          query.write(' ${entry.value[2]} ');
        }
      }
    }
    query.write(';');
    return query.toString();
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
    if (operatorOrValue is String && isSqlOperator(operatorOrValue)) {
      _whereMap[column] = [operatorOrValue, prepareSqlValue(value), 'AND'];
    } else {
      _whereMap[column] = ['=', prepareSqlValue(operatorOrValue), 'AND'];
    }
  }

  @override
  QueryBuilder where(String column, operatorOrValue, [value]) {
    _addWhere('AND', column, operatorOrValue, value);
    return this;
  }

  @override
  QueryBuilder orWhere(String column, operatorOrValue, [value]) {
    _addWhere('OR', column, operatorOrValue, value);
    return this;
  }
}
