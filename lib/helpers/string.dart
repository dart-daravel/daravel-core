/// Substitute variables in string.
String substituteVars(String input, Map<String, dynamic> vars) {
  // Use a regular expression to find placeholders like $VAR or ${VAR}
  final envVarPattern = RegExp(r'\$(\w+)|\$\{(\w+)\}');

  return input.replaceAllMapped(envVarPattern, (match) {
    // Extract the variable name
    String? varName = match.group(1) ?? match.group(2);
    // Substitute with the environment variable's value, or keep the placeholder if not found
    return vars[varName] ?? match.group(0)!;
  });
}
