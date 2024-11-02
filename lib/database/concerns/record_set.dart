abstract class RecordSet {
  Record? operator [](int index);
  bool get isEmpty;
  bool get isNotEmpty;
  int get length;
  Record? get first;
  Iterable<T> map<T>(T Function(Object) toElement);
}

abstract class Record {
  Object? operator [](String key);
}
