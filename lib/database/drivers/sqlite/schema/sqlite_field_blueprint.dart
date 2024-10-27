import 'package:daravel_core/database/schema/field_blueprint.dart';
import 'package:daravel_core/exceptions/query.dart';

class SqliteFieldBlueprint extends FieldBlueprint {
  SqliteFieldBlueprint(
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
  SqliteFieldBlueprint useCurrent() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' DEFAULT CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrent() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }

  @override
  SqliteFieldBlueprint useCurrentOnUpdate() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' ON UPDATE CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrentOnUpdate() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }

  @override
  SqliteFieldBlueprint comment(String comment) {
    throw UnimplementedError('SQLite does not support field comments');
  }

  @override
  SqliteFieldBlueprint unsigned() {
    throw UnimplementedError(
        'SQLite does not differentiate between signed and unsigned integers');
  }
}
