import 'package:daravel_core/database/schema/field_blueprint.dart';

class SqliteFieldBlueprint extends FieldBlueprint {
  SqliteFieldBlueprint(
    super.table,
    super.name,
    super.type, {
    super.isAutoIncrement,
    super.isPrimaryKey,
    super.constraint,
    super.isNullable,
    super.isUnique,
    super.defaultValue,
    super.fieldComment,
  });

  @override
  SqliteFieldBlueprint comment(String comment) {
    throw UnimplementedError('SQLite does not support field comments');
  }

  @override
  SqliteFieldBlueprint unsigned() {
    throw UnimplementedError(
        'SQLite does not differentiate between signed and unsigned integers');
  }

  @override
  SqliteFieldBlueprint useCurrent() {
    throw UnimplementedError(
        'useCurrent() is not supported by SQLite. Use a default value instead.');
  }

  @override
  SqliteFieldBlueprint useCurrentOnUpdate() {
    throw UnimplementedError(
        'useCurrentOnUpdate() is not supported by SQLite.');
  }
}
