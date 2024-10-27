import 'package:daravel_core/exceptions/query.dart';

abstract class FieldBlueprint {
  String table;
  String name;
  bool modify = false;
  String type;
  String? constraint;
  bool isNullable = false;
  bool isUnique = false;
  dynamic defaultValue;
  String? fieldComment;
  bool alter = false;
  bool isAutoIncrement;
  bool isUnsigned = true;
  bool isPrimaryKey;
  ForeignKeyConstraint? foreignKey;

  FieldBlueprint(
    this.table,
    this.name,
    this.type, {
    this.constraint,
    this.isAutoIncrement = false,
    this.isNullable = false,
    this.isUnique = false,
    this.defaultValue,
    this.isPrimaryKey = false,
    this.fieldComment,
  });

  FieldBlueprint change() {
    modify = true;
    return this;
  }

  FieldBlueprint nullable() {
    isNullable = true;
    return this;
  }

  FieldBlueprint unique() {
    isUnique = true;
    return this;
  }

  FieldBlueprint defaultsTo(dynamic value) {
    defaultValue = value;
    return this;
  }

  FieldBlueprint comment(String comment) {
    fieldComment = comment;
    return this;
  }

  FieldBlueprint primary([bool value = true]) {
    isPrimaryKey = value;
    return this;
  }

  FieldBlueprint autoIncrement() {
    isAutoIncrement = true;
    return this;
  }

  FieldBlueprint unsigned() {
    isUnsigned = true;
    return this;
  }

  ForeignKeyConstraint foreign() {
    foreignKey ??= ForeignKeyConstraint(table, name);
    return foreignKey!;
  }

  bool hasForeignKeyConstraint() {
    return foreignKey?.columnName != null &&
        foreignKey?.foreignColumnName != null &&
        foreignKey?.foreignTableName != null;
  }

  FieldBlueprint useCurrent() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' DEFAULT CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrent() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }

  FieldBlueprint useCurrentOnUpdate() {
    if (type == 'TIMESTAMP' || type == 'DATETIME') {
      type += ' ON UPDATE CURRENT_TIMESTAMP';
    } else {
      throw QueryException(
          'useCurrentOnUpdate() can only be used with TIMESTAMP or DATETIME');
    }
    return this;
  }
}

class ForeignKeyConstraint {
  String table;
  String columnName;
  String? foreignColumnName;
  String? foreignTableName;
  String? onDeleteAction;
  String? onUpdateAction;

  ForeignKeyConstraint(this.table, this.columnName);

  ForeignKeyConstraint references(String columnName) {
    foreignColumnName = columnName;
    return this;
  }

  ForeignKeyConstraint on(String tableName) {
    foreignTableName = tableName;
    return this;
  }

  ForeignKeyConstraint onDelete(String onDelete) {
    onDeleteAction = onDelete.toUpperCase();
    return this;
  }

  ForeignKeyConstraint onUpdate(String onUpdate) {
    onUpdateAction = onUpdate.toUpperCase();
    return this;
  }

  String get constraintName => '${table}_${columnName}_foreign';
}
