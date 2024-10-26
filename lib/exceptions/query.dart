class QueryException extends Error {
  final String message;

  QueryException(this.message);

  @override
  String toString() {
    return "QueryException: $message";
  }
}
