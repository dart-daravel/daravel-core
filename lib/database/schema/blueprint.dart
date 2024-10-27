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
}
