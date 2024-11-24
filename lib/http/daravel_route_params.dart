import 'package:daravel_core/http/middleware/middleware.dart';

class DaravelRouteParams {
  final List<DaravelMiddleware> middlewares = [];

  DaravelRouteParams middleware(DaravelMiddleware middleware) {
    middlewares.add(middleware);
    return this;
  }
}
