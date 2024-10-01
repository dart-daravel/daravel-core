import 'package:shelf/shelf.dart' as shelf;

abstract class DaravelMiddleware {
  shelf.Middleware handle();
}
