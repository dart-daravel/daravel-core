import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteRecordSet implements RecordSet {
  ResultSet result;

  SqliteRecordSet(this.result);

  @override
  Record? operator [](int index) => SqliteRecord(result[index]);

  @override
  bool get isEmpty => result.isEmpty;

  @override
  bool get isNotEmpty => result.isNotEmpty;

  @override
  int get length => result.length;

  @override
  Record? get first => SqliteRecord(result.first);

  @override
  Iterable<T> map<T>(T Function(Object record) toElement) =>
      result.map(toElement);
}

class SqliteRecord implements Record {
  final Row _row;

  SqliteRecord(this._row);

  @override
  Object? operator [](String key) => _row[key];
}
