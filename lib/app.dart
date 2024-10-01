import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:daravel_core/daravel_core.dart';

class DaravelApp {
  final List<DaravelRouter> routers;
  final List<DaravelMiddleware> globalMiddlewares;

  Handler? _rootHandler;

  DaravelApp({
    this.routers = const [],
    this.globalMiddlewares = const [],
  });

  Future<HttpServer> run({int port = 8080}) async {
    final rootRouter = Router();

    for (DaravelRouter router in routers) {
      router.setApp(this);
      rootRouter.mount('/', router.router.call);
    }

    var pipeline = const Pipeline();

    for (DaravelMiddleware middleware in globalMiddlewares) {
      pipeline = pipeline.addMiddleware(middleware.handle());
    }

    _rootHandler = pipeline.addHandler(rootRouter.call);

    // Use any available host or container IP (usually `0.0.0.0`).
    final ip = InternetAddress.anyIPv4;
    final server = await serve(_rootHandler!, ip, port);

    // ignore: avoid_print
    print('Server listening on port ${server.port}');

    return server;
  }

  Handler? get rootHandler => _rootHandler;
}
