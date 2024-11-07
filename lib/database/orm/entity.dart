import 'package:daravel_core/database/concerns/record.dart';

class Entity {
  Record data;

  Entity._(this.data);

  static Entity? fromRecord(Record? record) {
    return record != null ? Entity._(record) : null;
  }

  Map toJson() {
    final Map json = {};
    for (final key in data.keys) {
      json[key] = data[key];
    }
    return json;
  }
}
