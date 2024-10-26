class DBConnectionNotFoundException extends Error {
  final String connection;

  DBConnectionNotFoundException(this.connection);

  @override
  String toString() {
    return "DBConnectionNotFoundException: Connection '$connection' not found.";
  }
}
