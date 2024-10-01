import 'package:daravel_core/http/middleware/middleware.dart';
import 'package:shelf/shelf.dart';

class LoggerMiddleware implements DaravelMiddleware {
  @override
  Middleware handle() {
    return logRequests();
  }
}
