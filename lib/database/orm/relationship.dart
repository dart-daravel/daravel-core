class Relationship {
  final RelationshipType type;

  Relationship(this.type);
}

enum RelationshipType {
  hasOne,
  hasMany,
  belongsTo,
  belongsToMany,
}
