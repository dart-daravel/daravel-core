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

  SqliteFieldBlueprint change() {
    modify = true;
    return this;
  }

  SqliteFieldBlueprint nullable() {
    isNullable = true;
    return this;
  }

  SqliteFieldBlueprint unique() {
    isUnique = true;
    return this;
  }

  SqliteFieldBlueprint defaultsTo(dynamic value) {
    defaultValue = value;
    return this;
  }

  SqliteFieldBlueprint comment(String comment) {
    fieldComment = comment;
    return this;
  }

  SqliteFieldBlueprint primary(bool value) {
    isPrimaryKey = value;
    return this;
  }

  SqliteFieldBlueprint autoIncrement() {
    isAutoIncrement = true;
    return this;
  }

  ForeignKeyConstraint foreign() {
    foreignKey ??= ForeignKeyConstraint(name);
    return foreignKey!;
  }

  ForeignKeyConstraint references(String columnName) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.foreignColumnName = columnName;
    return foreignKey!;
  }

  ForeignKeyConstraint on(String tableName) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.foreignTableName = tableName;
    return foreignKey!;
  }

  SqliteFieldBlueprint onDelete(String onDelete) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.onDelete = onDelete.toUpperCase();
    return this;
  }

  SqliteFieldBlueprint onUpdate(String onUpdate) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.onUpdate = onUpdate.toUpperCase();
    return this;
  }

  SqliteFieldBlueprint useCurrent() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' DEFAULT CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrent() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }

  SqliteFieldBlueprint useCurrentOnUpdate() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' ON UPDATE CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrentOnUpdate() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }

  SqliteFieldBlueprint unsigned() {
    isUnsigned = true;
    return this;
  }
}
