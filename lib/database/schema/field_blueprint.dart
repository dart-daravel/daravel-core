abstract class FieldBlueprint {
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

  FieldBlueprint primary(bool value) {
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

  bool hasForeignKeyConstraint() {
    return foreignKey?.columnName != null &&
        foreignKey?.foreignColumnName != null &&
        foreignKey?.foreignTableName != null;
  }

  FieldBlueprint onDelete(String onDelete) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.onDelete = onDelete.toUpperCase();
    return this;
  }

  FieldBlueprint onUpdate(String onUpdate) {
    foreignKey ??= ForeignKeyConstraint(name);
    foreignKey!.onUpdate = onUpdate.toUpperCase();
    return this;
  }

  FieldBlueprint useCurrent();

  FieldBlueprint useCurrentOnUpdate();
}

class ForeignKeyConstraint {
  String columnName;
  String? foreignColumnName;
  String? foreignTableName;
  String? onDelete;
  String? onUpdate;

  ForeignKeyConstraint(this.columnName);
}
