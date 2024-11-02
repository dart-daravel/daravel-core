class ConsoleLogger {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  static ConsoleLogger? _instance;

  ConsoleLogger._();

  factory ConsoleLogger() {
    _instance ??= ConsoleLogger._();
    return _instance!;
  }

  void info(String message) {
    print('$blue[INFO] $white$message');
  }

  void success(String message) {
    print('$green[SUCCESS] $white$message');
  }

  void warning(String message) {
    print('$yellow[WARNING] $white$message');
  }

  void error(String message) {
    print('$red[ERROR] $white$message');
  }

  void debug(String message) {
    print('$magenta[DEBUG] $white[${DateTime.now()}] $message');
  }
}
