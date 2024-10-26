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

  bool hasForeignKeyConstraint() {
    return foreignKey?.columnName != null &&
        foreignKey?.foreignColumnName != null &&
        foreignKey?.foreignTableName != null;
  }
}

class ForeignKeyConstraint {
  String columnName;
  String? foreignColumnName;
  String? foreignTableName;
  String? onDelete;
  String? onUpdate;

  ForeignKeyConstraint(this.columnName);
}
