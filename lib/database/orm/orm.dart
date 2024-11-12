import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:pluralize/pluralize.dart';

abstract class ORM {
  String? get connection => null;

  String? get table => null;

  String? get primaryKey => 'id';

  Model get model;

  Map<String, Function>? get relationships => {};

  String get tableName =>
      table ?? tableFromModelClassName(runtimeType.toString());

  static String tableFromModelClassName(String className) =>
      Pluralize().plural(className.underscoreCase());

  DBDriver get _dbDriver => DB.connection(connection)!.driver;

  List<Entity> all() => _dbDriver
      .queryBuilder(tableName)
      .get()
      .map((e) => Entity.fromRecord(e as Record, relationships)!)
      .toList();

  QueryBuilder query() => _dbDriver.queryBuilder(
        tableName,
        model,
      );

  QueryBuilder where(dynamic column,
          [dynamic operatorOrValue, dynamic value]) =>
      _dbDriver
          .queryBuilder(tableName, model)
          .where(column, operatorOrValue, value);

  Entity? find(dynamic id) => Entity.fromRecord(
      _dbDriver.queryBuilder(tableName, model).find(id), relationships);

  Entity? first() => Entity.fromRecord(
      _dbDriver.queryBuilder(tableName, model).first(), relationships);

  Entity firstOrFail() => Entity.fromRecord(
      _dbDriver.queryBuilder(tableName, model).firstOrFail(), relationships)!;

  Entity create(Map<String, dynamic> values) {
    _dbDriver.queryBuilder(tableName, model).insert(values);
    return firstOrFail();
  }

  void chunk(int size, bool Function(RecordSet) callback) =>
      _dbDriver.queryBuilder(tableName, model).chunk(size, callback);

  void chunkById(int size, bool Function(RecordSet) callback) =>
      _dbDriver.queryBuilder(tableName, model).chunkById(size, callback);

  Future<int> delete(dynamic id) =>
      _dbDriver.queryBuilder(tableName, model).delete(id);

  LazyRecordSetGenerator lazy() =>
      _dbDriver.queryBuilder(tableName, model).lazy();

  LazyRecordSetGenerator lazyById() =>
      _dbDriver.queryBuilder(tableName, model).lazyById();
}
