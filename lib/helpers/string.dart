/// Substitute variables in string.
String substituteVars(String input, Map<String, dynamic> vars) {
  // Use a regular expression to find placeholders like $VAR or ${VAR}
  final varPattern = RegExp(r'\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\}\}');

  return input.replaceAllMapped(varPattern, (match) {
    // Extract the variable name
    String? varName = match.group(1);
    // Substitute with the environment variable's value, or keep the placeholder if not found
    return vars[varName] ?? match.group(0)!;
  });
}
