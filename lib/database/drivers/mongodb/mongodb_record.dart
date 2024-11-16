import 'package:daravel_core/database/concerns/record.dart';

class MongoDBRecord implements Record {
  final Map<String, dynamic> _record;

  MongoDBRecord(this._record);

  @override
  operator [](Object key) => _record[key];

  @override
  List<String> get keys => _record.keys.toList();
}
