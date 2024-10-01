import 'package:shelf/shelf.dart' as shelf;

abstract class Middleware {
  shelf.Middleware handle();
}
