import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/query_result.dart';
import 'package:daravel_core/helpers/database.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  DBDriver driver;

  final List<List<String>> _whereList = [];

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
    print(query);
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
    if (_whereList.isNotEmpty) {
      query.write(' WHERE ');
      for (var i = 0; i < _whereList.length; i++) {
        final entry = _whereList[i];
        query.write('${entry[0]} ${entry[1]} ${entry[2]}');
        if (i < _whereList.length - 1) {
          query.write(' ${entry[3]} ');
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
    // Add logic concatenator to the last entry.
    if (_whereList.isNotEmpty) {
      _whereList[_whereList.length - 1].add(logicConcatenator);
    }
    // Add new entry.
    if (operatorOrValue is String && isSqlOperator(operatorOrValue)) {
      _whereList.add([column, operatorOrValue, prepareSqlValue(value)]);
    } else {
      _whereList.add([column, '=', prepareSqlValue(operatorOrValue)]);
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
