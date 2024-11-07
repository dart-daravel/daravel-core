import 'package:sqlite3/sqlite3.dart';
import 'package:daravel_core/database/concerns/record.dart';

class SqliteRecord implements Record {
  final Row _row;

  SqliteRecord(this._row);

  @override
  Object? operator [](Object key) => _row[key];

  List<String> get keys => _row.keys;
}
