import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/orm/relationship.dart';
import 'package:daravel_core/globals.dart';

class Entity implements Record {
  Record? data;

  final Map<String, dynamic> _toSaveData = {};

  Map<String, Function>? relationships;

  Type model;

  Entity._(this.data, this.relationships, this.model);

  static Entity? fromRecord(Record? record, Type model,
      [Map<String, Function>? relationships]) {
    return record != null ? Entity._(record, relationships, model) : null;
  }

  static Entity fromType(Type model) {
    try {
      final resolvedModel =
          locator<ORM>(instanceName: '[orm]${model.toString()}');
      return Entity._(null, resolvedModel.relationships, model);
    } catch (e) {
      throw Exception('Could not resolve provided model with type: $model');
    }
  }

  Map toJson() => toMap();

  @override
  dynamic operator [](Object key) {
    if (key.toString().startsWith('=') &&
        (relationships?.containsKey(
                key.toString().substring(1).replaceFirst('()', '')) ??
            false)) {
      final relationship =
          relationships![key.toString().substring(1).replaceFirst('()', '')]!();
      if (relationship is Relationship) {
        return key.toString().endsWith('()')
            ? relationship.invoke(this)
            : relationship.resolve(this);
      }
      return null;
    }
    return data != null ? data![key] : _toSaveData[key];
  }

  /// Get the keys of the row map or column names.
  @override
  List<String> get keys => data?.keys ?? _toSaveData.keys.toList();

  @override
  void operator []=(String key, value) {
    data == null ? _toSaveData[key] = value : data![key] = value;
  }

  /// Save the entity to the database.
  /// The table for the model used by this entity must have a primary key.
  Future<void> save() async {
    final resolvedModel =
        locator<ORM>(instanceName: '[orm]${model.toString()}');
    if (resolvedModel.primaryKey == null) {
      resolvedModel.query().insert(toMap());
      return;
    }
    int modified = await resolvedModel
        .where(
            resolvedModel.primaryKey, data?[resolvedModel.primaryKey ?? 'id'])
        .update(toMap());
    if (modified == 0) {
      resolvedModel.query().insert(toMap());
    }
  }

  /// Returns a [Map<String, dynamic>] value of the entity.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (data != null) {
      for (final key in data?.keys ?? []) {
        map[key] = data?[key];
      }
      return map;
    } else {
      return _toSaveData;
    }
  }
}
