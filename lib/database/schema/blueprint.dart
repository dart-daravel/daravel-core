import 'package:daravel_core/database/schema/field_blueprint.dart';

abstract class Blueprint {
  String name;
  bool modify;
  List<FieldBlueprint> fields = [];
  String? engine;
  String? charset;
  String? collation;
  List<String> primaryKeys = [];
  List<String> compoundKeys = [];
  String? comment;
  List<String> columnsToDrop = [];
  List<String> indicesToDrop = [];
  List<String> foreignKeysToDrop = [];
  List<Index> indicesToCreate = [];
  List<List<String>> columnsToRename = [];

  Blueprint(this.name, this.modify);

  FieldBlueprint increments(String field);
  FieldBlueprint integer(String field,
      {bool autoIncrement = false, bool unsigned = false});
  FieldBlueprint bigIncrements(String field);
  FieldBlueprint string(String field, [int length = 100]);
  FieldBlueprint uuid([String field = 'uuid']);
  FieldBlueprint char(String field, [int length = 50]);
  FieldBlueprint date(String field);
  FieldBlueprint dateTime(String field);
  FieldBlueprint time(String field);
  FieldBlueprint timestamp(String field);
  ForeignKeyConstraint foreign(String field);
  FieldBlueprint text(String field);

  void renameColumn(String from, String to) => columnsToRename.add([from, to]);

  void dropColumn(String field) => columnsToDrop.add(field);

  void dropIndex(String name) => indicesToDrop.add(name);

  void primary(List<String> fields) => primaryKeys.addAll(fields);

  void index(dynamic field, [String? name, String? algorithm]) {
    assert(field is String || field is List<String>);
    indicesToCreate.add(Index(
      this.name,
      name,
      field is String ? [field] : field,
    ));
  }
}

class Index {
  String table;
  String? name;
  List<String> columns;

  Index(this.table, this.name, this.columns);

  String get indexName => name ?? '${columns.join('_')}_index';
}
