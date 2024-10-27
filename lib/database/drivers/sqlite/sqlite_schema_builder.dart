import 'package:daravel_core/database/concerns/schema_builder.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

class SqliteSchemaBuilder extends SchemaBuilder {
  final SQLiteDriver _driver;

  SqliteSchemaBuilder(this._driver);

  @override
  String executeCreateBlueprint(Blueprint blueprint) {
    String foreignKeyConstraints = '';
    String query = 'CREATE TABLE ${blueprint.name} (';
    for (final field in blueprint.fields) {
      if (field.type.isNotEmpty) {
        query += '${field.name} ${field.type}';

        if (field.constraint != null) {
          query += '(${field.constraint})';
        }

        if (field.isPrimaryKey) {
          query += ' PRIMARY KEY';
        }

        if (field.isAutoIncrement) {
          query += ' AUTOINCREMENT';
        }

        if (field.isUnique) {
          query += ' UNIQUE';
        }

        if (!field.isNullable) {
          query += ' NOT NULL';
        }

        if (field.defaultValue != null) {
          query += ' DEFAULT ${_prepareValue(field.defaultValue)}';
        }

        if (field.name != blueprint.fields.last.name) {
          query += ', ';
        }
      }

      if (field.hasForeignKeyConstraint()) {
        final prefix =
            '${foreignKeyConstraints.isEmpty ? '' : ', '}CONSTRAINT ${field.foreignKey!.constraintName} ';
        foreignKeyConstraints +=
            '${prefix}FOREIGN KEY (${field.foreignKey!.columnName}) REFERENCES ${field.foreignKey!.foreignTableName}(${field.foreignKey!.foreignColumnName})';
        if (field.foreignKey!.onDeleteAction != null) {
          foreignKeyConstraints +=
              ' ON DELETE ${field.foreignKey!.onDeleteAction}';
        }
        if (field.foreignKey!.onUpdateAction != null) {
          foreignKeyConstraints +=
              ' ON UPDATE ${field.foreignKey!.onUpdateAction}';
        }
      }
    }

    if (blueprint.primaryKeys.isNotEmpty) {
      query += ', PRIMARY KEY(';
      for (final key in blueprint.primaryKeys) {
        query += ' $key';
        if (key != blueprint.primaryKeys.last) {
          query += ',';
        }
      }
      query += ')';
    }

    if (foreignKeyConstraints.isNotEmpty) {
      query += ', $foreignKeyConstraints';
    }

    query += ');';

    _driver.statement(query);

    return query;
  }

  String _prepareValue(dynamic value) {
    return value is String ? "'$value'" : value;
  }

  @override
  String drop(String table) {
    final query = 'DROP TABLE $table;';
    _driver.statement(query);
    return query;
  }

  @override
  String dropIfExists(String table) {
    final query = 'DROP TABLE IF EXISTS $table;';
    _driver.statement(query);
    return query;
  }

  @override
  String renameTable(String from, String to) {
    final query = 'ALTER TABLE $from RENAME TO $to;';
    _driver.statement(query);
    return query;
  }
}
