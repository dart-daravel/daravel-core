import 'package:daravel_core/database/schema/blueprint.dart';

abstract class SchemaBuilder {
  /// Builds and executes a CREATE TABLE or ALTER TABLE statement from a [Blueprint] object.
  String executeBlueprint(Blueprint blueprint) {
    return '';
  }

  String renameTable(String from, String to);

  String drop(String table);

  String dropIfExists(String table);
}
