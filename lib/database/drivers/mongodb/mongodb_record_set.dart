import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/drivers/mongodb/mongodb_record.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/database/orm/orm.dart';

class MongodbRecordSet implements RecordSet {
  final List<Map<String, dynamic>> _result;

  @override
  ORM? orm;

  MongodbRecordSet(this._result, [this.orm]);

  @override
  Record operator [](int index) {
    throw UnimplementedError();
  }

  @override
  Record get first => MongoDBRecord(_result.first);

  @override
  bool get isEmpty => _result.isEmpty;

  @override
  bool get isNotEmpty => _result.isNotEmpty;

  @override
  int get length => _result.length;

  @override
  Iterable<T> map<T>(T Function(Object record) toElement) =>
      _result.map((e) => toElement(orm != null
          ? Entity.fromRecord(
              MongoDBRecord(e),
              orm.runtimeType,
            )!
          : MongoDBRecord(e)));
}
