abstract class QueryResult {
  List<List<Object?>> get rows;
  List<Map<String, Object?>>? get mappedRows;
  Object? get resultObject;
}
