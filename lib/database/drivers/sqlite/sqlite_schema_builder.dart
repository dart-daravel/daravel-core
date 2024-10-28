import 'package:daravel_core/database/concerns/schema_builder.dart';
import 'package:daravel_core/database/drivers/sqlite/sqlite.dart';
import 'package:daravel_core/database/schema/blueprint.dart';

class SqliteSchemaBuilder extends SchemaBuilder {
  final SQLiteDriver _driver;

  SqliteSchemaBuilder(this._driver);

  @override
  String executeBlueprint(Blueprint blueprint) {
    if (blueprint.modify) {
      return _modifyTable(blueprint);
    } else {
      return _createTable(blueprint);
    }
  }

  String _createTable(Blueprint blueprint) {
    final StringBuffer foreignKeyConstraints = StringBuffer();
    final StringBuffer indices = StringBuffer();
    final StringBuffer query = StringBuffer('CREATE TABLE ${blueprint.name} (');
    for (final field in blueprint.fields) {
      if (field.type.isNotEmpty) {
        query.write('${field.name} ${field.type}');

        if (field.constraint != null) {
          query.write('(${field.constraint})');
        }

        if (field.isPrimaryKey) {
          query.write(' PRIMARY KEY');
        }

        if (field.isAutoIncrement) {
          query.write(' AUTOINCREMENT');
        }

        if (field.isUnique) {
          query.write(' UNIQUE');
        }

        if (!field.isNullable) {
          query.write(' NOT NULL');
        }

        if (field.defaultValue != null) {
          query.write(' DEFAULT ${_prepareValue(field.defaultValue)}');
        }

        if (field.name != blueprint.fields.last.name) {
          query.write(', ');
        }
      }

      if (field.isIndex) {
        indices.write(
            _createIndexStatement(blueprint.name, field.name, field.indexName));
      }

      if (field.hasForeignKeyConstraint()) {
        final prefix =
            '${foreignKeyConstraints.isEmpty ? '' : ', '}CONSTRAINT ${field.foreignKey!.constraintName} ';
        foreignKeyConstraints.write(
            '${prefix}FOREIGN KEY (${field.foreignKey!.columnName}) REFERENCES ${field.foreignKey!.foreignTableName}(${field.foreignKey!.foreignColumnName})');
        if (field.foreignKey!.onDeleteAction != null) {
          foreignKeyConstraints
              .write(' ON DELETE ${field.foreignKey!.onDeleteAction}');
        }
        if (field.foreignKey!.onUpdateAction != null) {
          foreignKeyConstraints
              .write(' ON UPDATE ${field.foreignKey!.onUpdateAction}');
        }
      }
    }

    if (blueprint.primaryKeys.isNotEmpty) {
      query.write(', PRIMARY KEY (');
      for (final key in blueprint.primaryKeys) {
        query.write(key);
        if (key != blueprint.primaryKeys.last) {
          query.write(', ');
        }
      }
      query.write(')');
    }

    if (foreignKeyConstraints.isNotEmpty) {
      query.write(', $foreignKeyConstraints');
    }

    query.writeln(');');

    if (indices.length > 0) {
      query.writeln(indices.toString());
    }

    for (final index in blueprint.indicesToCreate) {
      query.writeln(
          _createIndexStatement(blueprint.name, index.columns, index.name));
    }

    _driver.statement(query.toString());

    return query.toString().trim();
  }

  String _modifyTable(Blueprint blueprint) {
    StringBuffer query = StringBuffer();
    if (blueprint.fields.isNotEmpty) {
      for (final field in blueprint.fields) {
        query.writeln(
            'ALTER TABLE ${blueprint.name} ADD COLUMN ${field.name} ${field.type};');
      }
    }
    if (blueprint.columnsToDrop.isNotEmpty) {
      for (final column in blueprint.columnsToDrop) {
        query.writeln('ALTER TABLE ${blueprint.name} DROP COLUMN $column;');
      }
    }
    if (blueprint.indexesToDrop.isNotEmpty) {
      for (final index in blueprint.indexesToDrop) {
        query.writeln('DROP INDEX $index;');
      }
    }
    if (blueprint.indicesToCreate.isNotEmpty) {
      for (final index in blueprint.indicesToCreate) {
        query.writeln(_createIndexStatement(
            index.table, index.columns.join(', '), index.name));
      }
    }
    _driver.statement(query.toString());
    return query.toString();
  }

  String _prepareValue(dynamic value) {
    return value is String ? "'$value'" : value;
  }

  /// Generates a CREATE INDEX statement
  ///
  /// [column] can either be a [String] or [List<String>], i.e either a column,
  /// or a list of columns.
  String _createIndexStatement(String table, dynamic column, [String? name]) {
    assert(column is String || column is List<String>);
    return column is String
        ? 'CREATE INDEX ${name ?? '${column}_index'} ON $table ($column);'
        : 'CREATE INDEX ${name ?? '${(column as List<String>).join('_')}_index'} ON $table (${(column as List<String>).join(', ')});';
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
