class ComponentNotBootedException extends Error {
  final String message;

  ComponentNotBootedException(this.message);

  @override
  String toString() {
    return "ComponentNotBootedException: $message";
  }
}
