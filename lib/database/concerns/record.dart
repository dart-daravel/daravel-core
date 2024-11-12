abstract class Record {
  dynamic operator [](Object key);

  void operator []=(String key, dynamic value);

  List<String> get keys;
}
