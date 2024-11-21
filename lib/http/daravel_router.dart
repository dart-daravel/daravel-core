import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:daravel_core/core.dart';
import 'package:daravel_core/http/middleware/middleware.dart';

class DaravelRouteParams {
  final List<DaravelMiddleware> middlewares = [];

  DaravelRouteParams middleware(DaravelMiddleware middleware) {
    middlewares.add(middleware);
    return this;
  }
}

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

class DaravelRouter {
  DaravelRouter();

  String? _domain;

  final List<DaravelRoute> _routes = [];
  final List<DaravelRouter> _routers = [];

  late final Core app;

  void setApp(Core app) {
    this.app = app;
  }

  /// Define a route with the GET method
  DaravelRouteParams get(String path, Function handler) {
    final route = DaravelRoute('GET', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the POST method
  DaravelRouteParams post(String path, Function handler) {
    final route = DaravelRoute('POST', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the PUT method
  DaravelRouteParams put(String path, Function handler) {
    final route = DaravelRoute('PUT', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the PATCH method
  DaravelRouteParams patch(String path, Function handler) {
    final route = DaravelRoute('PATCH', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route for all HTTP methods
  DaravelRouteParams any(String path, Function handler) {
    final route = DaravelRoute('', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the OPTIONS method
  DaravelRouteParams options(String path, Function handler) {
    final route = DaravelRoute('OPTIONS', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the HEAD method
  DaravelRouteParams head(String path, Function handler) {
    final route = DaravelRoute('HEAD', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the DELETE method
  DaravelRouteParams delete(String path, Function handler) {
    final route = DaravelRoute('DELETE', path, handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with custom method
  DaravelRouteParams add(String method, String path, Function handler) {
    final route = DaravelRoute(method, path, handler);
    _routes.add(route);
    return route.params;
  }

  void group(String path, Function(DaravelRouter) callback) {
    final router = DaravelRouter();
    callback(router);

    _routes.add(DaravelRoute('', path.isEmpty ? '/' : path, null,
        routes: router.routes));
  }

  DaravelRouter domain(String domain) {
    final router = DaravelRouter();
    router._domain = domain;

    _routers.add(router);

    return router;
  }

  List<DaravelRoute> get routes => _routes;

  /// Get router
  Router get router {
    final router = Router();
    _buildRoutes(_routes, router);
    if (_routers.isNotEmpty) {
      for (final r in _routers) {
        _mountDaravelRouter(r, router);
      }
    }
    return router;
  }

  void _mountDaravelRouter(DaravelRouter daravelRouter, Router router) {
    if (daravelRouter._routers.isNotEmpty) {
      for (final r in daravelRouter._routers) {
        _mountDaravelRouter(r, router);
      }
    } else {
      router.mount('/', daravelRouter.router.call);
    }
  }

  /// Build routes
  void _buildRoutes(List<DaravelRoute> routes, Router router,
      {Router? parentRouter, String? groupPrefix}) {
    String lastGroupPrefix = '';

    for (final route in routes) {
      if (route.routes.isEmpty) {
        _mountRoute(router, route);
        if (groupPrefix != null) {
          parentRouter?.mount("$groupPrefix$lastGroupPrefix", router.call);
        }
      } else {
        // Grouped routes - Recursive section
        lastGroupPrefix += route.path;
        final nestedRouter = Router();
        _buildRoutes(route.routes, nestedRouter,
            groupPrefix: lastGroupPrefix, parentRouter: router);
        lastGroupPrefix = lastGroupPrefix.replaceAll(route.path, '');
      }
    }
  }

  void _mountRoute(Router router, DaravelRoute route) {
    var pipeline = const Pipeline();
    if (_domain != null) {
      pipeline = pipeline.addMiddleware(_domainHandler(router, _domain!));
    }
    for (final middleware in route.params.middlewares) {
      pipeline = pipeline.addMiddleware(middleware.handle());
    }
    final handler = pipeline.addHandler((
      Request req, [
      String? a1,
      String? a2,
      String? a3,
      String? a4,
      String? a5,
      String? a6,
    ]) {
      return Function.apply(route.handler!, [req, ...req.params.values]);
    });
    if (route.method.isEmpty) {
      router.all(route.path, handler);
    } else {
      router.add(route.method, route.path, handler);
    }
  }
}

Middleware _domainHandler(Router? router, String domain) {
  return (Handler innerHandler) {
    return (Request request) {
      final host = request.headers[HttpHeaders.hostHeader] ?? '';
      if (router != null && host.startsWith(domain)) {
        return innerHandler(request);
      }
      return Response.notFound('Not found');
    };
  };
}
