import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteRecordSet implements RecordSet {
  final ResultSet _result;

  @override
  ORM? orm;

  SqliteRecordSet(this._result, [this.orm]);

  @override
  Record operator [](int index) => orm != null
      ? Entity.fromRecord(
          SqliteRecord(_result[index]), orm.runtimeType, orm!.relationships)!
      : SqliteRecord(_result[index]);

  @override
  bool get isEmpty => _result.isEmpty;

  @override
  bool get isNotEmpty => _result.isNotEmpty;

  @override
  int get length => _result.length;

  @override
  Record get first => SqliteRecord(_result.first);

  @override
  Iterable<T> map<T>(T Function(Object record) toElement) =>
      _result.map((e) => toElement(orm != null
          ? Entity.fromRecord(
              SqliteRecord(e),
              orm.runtimeType,
            )!
          : SqliteRecord(e)));
}
