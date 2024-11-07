import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/database/concerns/db_driver.dart';
import 'package:daravel_core/database/concerns/record_set.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:pluralize/pluralize.dart';

abstract class ORM {
  String? get connection => null;

  String? get table => null;

  Map get attributes => {};

  String get _tableName =>
      table ?? Pluralize().plural(runtimeType.toString().underscoreCase());

  DBDriver get _dbDriver => DB.connection(connection)!.driver;

  RecordSet all() => _dbDriver.queryBuilder(_tableName).get();

  QueryBuilder query() => _dbDriver.queryBuilder(_tableName);

  QueryBuilder where(dynamic column,
          [dynamic operatorOrValue, dynamic value]) =>
      _dbDriver.queryBuilder(_tableName).where(column, operatorOrValue, value);

  QueryBuilder orWhere(dynamic column,
          [dynamic operatorOrValue, dynamic value]) =>
      _dbDriver
          .queryBuilder(_tableName)
          .orWhere(column, operatorOrValue, value);

  Entity? find(dynamic id) =>
      Entity.fromRecord(_dbDriver.queryBuilder(_tableName).find(id));

  Entity? first() =>
      Entity.fromRecord(_dbDriver.queryBuilder(_tableName).first());

  Entity firstOrFail() =>
      Entity.fromRecord(_dbDriver.queryBuilder(_tableName).firstOrFail())!;

  Entity create(Map<String, dynamic> values) {
    _dbDriver.queryBuilder(_tableName).insert(values);
    return firstOrFail();
  }

  Future<int> insertGetId(Map<String, dynamic> values) =>
      _dbDriver.queryBuilder(_tableName).insertGetId(values);
}
