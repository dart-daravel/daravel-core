import 'package:daravel_core/http/daravel_route_params.dart';

class DaravelRoute {
  final String method;
  final String path;
  final Function? handler;
  final List<DaravelRoute> routes;
  final DaravelRouteParams params = DaravelRouteParams();

  DaravelRoute(
    this.method,
    this.path,
    this.handler, {
    this.routes = const [],
  });
}
