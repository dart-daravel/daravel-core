class Logger {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  String? lastColor;

  void info(String message) {
    _switchColor(blue);
    print('[INFO] $message');
  }

  void _switchColor(String color) {
    if (lastColor == color) return;
    print(color);
    lastColor = color;
  }

  void success(String message) {
    _switchColor(green);
    print('[SUCCESS] $message');
  }

  void warning(String message) {
    _switchColor(yellow);
    print('[WARNING] $message');
  }

  void error(String message) {
    _switchColor(red);
    print('[ERROR] $message');
  }
}
