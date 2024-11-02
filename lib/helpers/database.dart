bool isSqlOperator(String string) {
  return ['=', '>', '<', '>=', '<=', '!=', '<>', 'LIKE'].contains(string);
}

String prepareSqlValue(dynamic value) {
  if (value is bool) {
    return value ? '1' : '0';
  } else if (value is String) {
    return "'$value'";
  }
  return value.toString();
}

Map<String, dynamic> mapRow(List<String> columns, List<Object?> row) {
  final map = <String, dynamic>{};
  for (var i = 0; i < columns.length; i++) {
    map[columns[i]] = row[i];
  }
  return map;
}
