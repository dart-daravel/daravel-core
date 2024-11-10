import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/orm/relationship.dart';

class Entity implements Record {
  Record data;

  Map<String, Function>? relationships;

  Entity._(this.data, this.relationships);

  static Entity? fromRecord(Record? record,
      [Map<String, Function>? relationships]) {
    return record != null ? Entity._(record, relationships) : null;
  }

  Map toJson() {
    final Map json = {};
    for (final key in data.keys) {
      json[key] = data[key];
    }
    return json;
  }

  @override
  dynamic operator [](Object key) {
    if (key.toString().startsWith('=') &&
        (relationships?.containsKey(
                key.toString().substring(1).replaceFirst('()', '')) ??
            false)) {
      return key.toString().endsWith('()')
          ? relationships![key.toString().substring(1)]!()
          : (relationships![key.toString().substring(1)]!() as Relationship)
              .resolve(this);
    }
    return data[key];
  }

  @override
  List<String> get keys => data.keys;
}
