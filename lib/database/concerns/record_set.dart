import 'package:daravel_core/database/concerns/record.dart';

abstract class RecordSet {
  Record operator [](int index);
  bool get isEmpty;
  bool get isNotEmpty;
  int get length;
  Record get first;
  Iterable<T> map<T>(T Function(Object) toElement);
}
