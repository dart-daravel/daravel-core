import 'dart:io';

import 'package:daravel_core/http/daravel_route.dart';
import 'package:daravel_core/http/daravel_route_params.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:daravel_core/core.dart';

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
    final route = DaravelRoute('GET', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the POST method
  DaravelRouteParams post(String path, Function handler) {
    final route = DaravelRoute('POST', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the PUT method
  DaravelRouteParams put(String path, Function handler) {
    final route = DaravelRoute('PUT', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the PATCH method
  DaravelRouteParams patch(String path, Function handler) {
    final route = DaravelRoute('PATCH', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route for all HTTP methods
  DaravelRouteParams any(String path, Function handler) {
    final route = DaravelRoute('', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the OPTIONS method
  DaravelRouteParams options(String path, Function handler) {
    final route = DaravelRoute('OPTIONS', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the HEAD method
  DaravelRouteParams head(String path, Function handler) {
    final route = DaravelRoute('HEAD', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with the DELETE method
  DaravelRouteParams delete(String path, Function handler) {
    final route = DaravelRoute('DELETE', _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  /// Define a route with custom method
  DaravelRouteParams add(String method, String path, Function handler) {
    final route = DaravelRoute(method, _adaptPath(path), handler);
    _routes.add(route);
    return route.params;
  }

  DaravelRouteParams group(String path, Function(DaravelRouter) callback) {
    final router = DaravelRouter();
    callback(router);
    final route =
        DaravelRoute('', _adaptPath(path), null, routes: router.routes);
    _routes.add(route);
    return route.params;
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
      {Router? parentRouter,
      String? groupPrefix,
      DaravelRouteParams? routeParams}) {
    String lastGroupPrefix = '';

    for (final route in routes) {
      if (route.routes.isEmpty) {
        _mountRoute(router, route, routeParams);
        if (groupPrefix != null) {
          parentRouter?.mount("$groupPrefix$lastGroupPrefix", router.call);
        }
      } else {
        // Grouped routes - Recursive section
        lastGroupPrefix += route.path;
        final nestedRouter = Router();
        _buildRoutes(route.routes, nestedRouter,
            groupPrefix: lastGroupPrefix,
            parentRouter: router,
            routeParams: route.params);
        lastGroupPrefix = lastGroupPrefix.replaceAll(route.path, '');
      }
    }
  }

  void _mountRoute(Router router, DaravelRoute route,
      [DaravelRouteParams? params]) {
    var pipeline = const Pipeline();
    if (_domain != null) {
      pipeline = pipeline.addMiddleware(_domainHandler(router, _domain!));
    }
    for (final middleware in route.params.middlewares) {
      pipeline = pipeline.addMiddleware(middleware.handle());
    }
    if (params != null && params.middlewares.isNotEmpty) {
      for (final middleware in params.middlewares) {
        pipeline = pipeline.addMiddleware(middleware.handle());
      }
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

  String _adaptPath(String path) =>
      path.isEmpty ? '/' : path.replaceAll('{', '<').replaceAll('}', '>');
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
