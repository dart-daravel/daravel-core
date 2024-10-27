import 'package:daravel_core/database/drivers/sqlite/schema/sqlite_field_blueprint.dart';
import 'package:daravel_core/database/schema/blueprint.dart';
import 'package:daravel_core/database/schema/field_blueprint.dart';

class SqliteBlueprint extends Blueprint {
  SqliteBlueprint(super.name, super.modify);

  @override
  SqliteFieldBlueprint increments(String field) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'INTEGER',
      isAutoIncrement: true,
      isPrimaryKey: true,
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  SqliteFieldBlueprint bigIncrements(String field) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'INTEGER',
      isAutoIncrement: true,
      isPrimaryKey: true,
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  SqliteFieldBlueprint string(String field, [int length = 100]) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'VARCHAR',
      constraint: length.toString(),
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  SqliteFieldBlueprint uuid([String field = 'uuid']) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'CHAR',
      constraint: '36',
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  SqliteFieldBlueprint char(String field, [int length = 50]) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'CHAR',
      constraint: length.toString(),
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  SqliteFieldBlueprint date(String field) {
    final blueprint = SqliteFieldBlueprint(field, 'DATE');
    fields.add(blueprint);
    return blueprint;
  }

  @override
  FieldBlueprint integer(String field,
      {bool autoIncrement = false, bool unsigned = false}) {
    final blueprint = SqliteFieldBlueprint(
      field,
      'INTEGER',
      isAutoIncrement: autoIncrement,
    );
    fields.add(blueprint);
    return blueprint;
  }

  @override
  FieldBlueprint dateTime(String field) {
    throw UnimplementedError();
  }

  @override
  FieldBlueprint time(String field) {
    throw UnimplementedError();
  }

  @override
  FieldBlueprint timestamp(String field) {
    throw UnimplementedError();
  }
}
