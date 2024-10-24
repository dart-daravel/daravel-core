extension StringExtension on String {
  /// Make first character uppercase.
  /// e.g hello -> Hello
  String ucfirst() => replaceFirstMapped(RegExp(r'^[a-z]'), (match) {
        return match.group(0)!.toUpperCase();
      });

  /// Replace space and hyphen with underscore, adds underscore
  /// between lower and upper case characters, and returns string
  /// as lower case characters.
  /// e.g. Hello world -> hello_word, HelloWorld  -> hello_world
  String underscoreCase() => replaceAll(RegExp(r'\s|-'), '_')
          .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (Match match) {
        return '${match.group(1)}_${match.group(2)}';
      }).toLowerCase();
}
