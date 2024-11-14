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

  /// Replace hyphens, space, and underscore, and compacts the text, leaving
  /// Uppercase characters where there once was hyphens, space, and underscore.
  String classCase() => replaceAll(RegExp(r'[-_\s]'), ' ')
      .split(' ')
      .map((e) => e.ucfirst())
      .join();

  String camelCase() {
    if (isEmpty) return this;

    final List<String> words = split(RegExp(r'(?=[A-Z])|[\s_\-]+'));
    final StringBuffer camelCaseString = StringBuffer(words[0].toLowerCase());

    for (int i = 1; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        camelCaseString.write(
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase());
      }
    }

    return camelCaseString.toString();
  }

  /// Removes specified character from the end of the string.
  ///
  /// e.g. 'hello'.rtrim('o') -> 'hell'
  String rtrim(String char) => endsWith(char) ? substring(0, length - 1) : this;

  /// Removes specified character from the start of the string.
  ///
  /// e.g. 'hello'.ltrim('h') -> 'ello'
  String ltrim(String char) => startsWith(char) ? substring(1) : this;
}
