class DatabaseConnection {
  String driver;
  String? url;
  String? database;
  String? prefix;
  bool? foreignKeyConstraints;
  int? busyTimeout;
  String? journalMode;
  String? synchronous;
  bool queryLog;

  DatabaseConnection({
    this.driver = 'sqlite',
    this.url,
    this.database,
    this.prefix,
    this.foreignKeyConstraints,
    this.busyTimeout,
    this.journalMode,
    this.synchronous,
    this.queryLog = false,
  });
}
