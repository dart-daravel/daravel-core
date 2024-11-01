import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/concerns/query_result.dart';

class SQLiteQueryBuilder implements QueryBuilder {
  @override
  String? table;

  @override
  DBDriver driver;

  Map<String, dynamic> _insertMap = {};

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

  String _parseSelectColumn(String column) =>
      column.startsWith('[=]') ? column.substring(3) : column;

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
    query.write(' FROM $table');
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
}
