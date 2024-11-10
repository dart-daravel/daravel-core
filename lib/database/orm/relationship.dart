import 'package:daravel_core/database/concerns/query_builder.dart';
import 'package:daravel_core/database/orm/entity.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:pluralize/pluralize.dart';

class Relationship {
  final RelationshipType type;

  final QueryBuilder queryBuilder;

  final ORM primaryModel;

  final String? localKey;

  late final String foreignKey;

  Relationship(
      this.type, this.primaryModel, Type relatedModel, this.queryBuilder,
      [String? foreignKey, String? foreignTable, this.localKey]) {
    queryBuilder.table =
        foreignTable ?? ORM.tableFromModelClassName(relatedModel.toString());
    if (type == RelationshipType.hasOne || type == RelationshipType.hasMany) {
      this.foreignKey =
          foreignKey ?? '${Pluralize().singular(primaryModel.tableName)}_id';
    } else if (type == RelationshipType.belongsToMany) {
      this.foreignKey =
          foreignKey ?? '${Pluralize().singular(primaryModel.tableName)}_id';
    } else {
      this.foreignKey = foreignKey ??
          (type == RelationshipType.belongsToMany
              ? '${Pluralize().singular(primaryModel.tableName)}_id'
              : 'id');
    }
  }

  Object? resolve(Entity primaryEntity) {
    switch (type) {
      case RelationshipType.hasOne:
        return queryBuilder
            .where(foreignKey, '=',
                primaryEntity[localKey ?? primaryModelPrimaryKey])
            .first();
      case RelationshipType.hasMany:
        return queryBuilder
            .where(foreignKey, '=',
                primaryEntity[localKey ?? primaryModelPrimaryKey])
            .get();
      case RelationshipType.belongsTo:
        return queryBuilder
            .where(foreignKey, '=',
                primaryEntity[localKey ?? primaryModelPrimaryKey])
            .first();
      case RelationshipType.belongsToMany:
        return queryBuilder
            .where(foreignKey, '=',
                primaryEntity[localKey ?? primaryModelPrimaryKey])
            .get();
    }
  }

  String get primaryModelPrimaryKey {
    return primaryModel.primaryKey ?? 'id';
  }
}

enum RelationshipType {
  hasOne,
  hasMany,
  belongsTo,
  belongsToMany,
}
