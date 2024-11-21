import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/orm/orm.dart';

abstract class RecordSet {
  ORM? orm;
  Record operator [](int index);
  bool get isEmpty;
  bool get isNotEmpty;
  int get length;
  Record get first;
  Iterable<T> map<T>(T Function(Object) toElement);
}
