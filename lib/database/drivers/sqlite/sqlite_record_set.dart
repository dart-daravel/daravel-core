import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite_record.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteRecordSet implements RecordSet {
  ResultSet result;

  @override
  ORM? orm;

  SqliteRecordSet(this.result, [this.orm]);

  @override
  Record operator [](int index) => orm != null
      ? Entity.fromRecord(
          SqliteRecord(result[index]), orm.runtimeType, orm!.relationships)!
      : SqliteRecord(result[index]);

  @override
  bool get isEmpty => result.isEmpty;

  @override
  bool get isNotEmpty => result.isNotEmpty;

  @override
  int get length => result.length;

  @override
  Record get first => SqliteRecord(result.first);

  @override
  Iterable<T> map<T>(T Function(Object record) toElement) =>
      result.map((e) => toElement(orm != null
          ? Entity.fromRecord(
              SqliteRecord(e),
              orm.runtimeType,
            )!
          : SqliteRecord(e)));
}
