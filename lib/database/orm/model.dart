import 'package:daravel_core/database/db.dart';
import 'package:daravel_core/database/orm/orm.dart';
import 'package:daravel_core/database/orm/relationship.dart';

abstract class Model extends ORM {
  @override
  Model get model => this;

  Relationship hasOne(Type related,
      {String? foreignKey, String? localKey, String? foreignTable}) {
    return Relationship(
      RelationshipType.hasOne,
      this,
      related,
      DB.connection(connection)!.driver.queryBuilder(tableName, this),
      foreignKey,
      foreignTable,
      localKey,
    );
  }

  Relationship belongsTo(Type related,
      {String? foreignKey, String? localKey, String? foreignTable}) {
    return Relationship(
      RelationshipType.belongsTo,
      this,
      related,
      DB.connection(connection)!.driver.queryBuilder(tableName, this),
      foreignKey,
      foreignTable,
      localKey,
    );
  }

  Relationship hasMany(Type related,
      {String? foreignKey, String? localKey, String? foreignTable}) {
    return Relationship(
      RelationshipType.hasMany,
      this,
      related,
      DB.connection(connection)!.driver.queryBuilder(tableName, this),
      foreignKey,
      foreignTable,
      localKey,
    );
  }

  Relationship belongsToMany(Type related,
      {String? foreignKey, String? localKey, String? foreignTable}) {
    return Relationship(
      RelationshipType.belongsToMany,
      this,
      related,
      DB.connection(connection)!.driver.queryBuilder(tableName, this),
      foreignKey,
      foreignTable,
      localKey,
    );
  }
}
