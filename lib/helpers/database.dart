bool isSqlOperator(String string) {
  return ['=', '>', '<', '>=', '<=', '!=', '<>', 'LIKE'].contains(string);
}

String prepareSqlValue(dynamic value) {
  if (value is bool) {
    return value ? '1' : '0';
  } else if (value is String) {
    return "'$value'";
  }
  return value;
}
