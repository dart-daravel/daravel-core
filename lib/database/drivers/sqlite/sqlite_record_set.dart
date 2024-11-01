import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteRecordSet implements RecordSet {
  ResultSet result;
  List<SqliteRecord>? _mappedRows;

  SqliteRecordSet(this.result);

  @override
  Record? operator [](int index) => _getMappedRows()[index];

  List<SqliteRecord> _getMappedRows() {
    _mappedRows ??= result.rows.map((e) {
      final map = <String, Object?>{};
      for (var x = 0; x < result.columnNames.length; x++) {
        map[result.columnNames[x]] = e[x];
      }
      return SqliteRecord(map);
    }).toList();
    return _mappedRows!;
  }

  @override
  bool get isEmpty => result.isEmpty;

  @override
  bool get isNotEmpty => result.isNotEmpty;

  @override
  int get length => result.length;

  @override
  Record? get first => _getMappedRows().first;

  @override
  Iterable<T> map<T>(T Function(Record record) toElement) =>
      _getMappedRows().map(toElement);
}

class SqliteRecord implements Record {
  final Map<String, Object?> _row;

  SqliteRecord(this._row);

  @override
  Object? operator [](String key) => _row[key];
}
