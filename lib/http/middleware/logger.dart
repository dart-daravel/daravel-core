import 'package:daravel_core/http/middleware/middleware.dart' as daravel;
import 'package:shelf/shelf.dart';

class LoggerMiddleware implements daravel.Middleware {
  @override
  Middleware handle() {
    return logRequests();
  }
}
