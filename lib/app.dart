import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/http/daravel_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:daravel_core/http/middleware/middleware.dart' as daravel;

class DaravelApp {
  final List<DaravelRouter> routers;
  final List<daravel.Middleware> globalMiddlewares;

  const DaravelApp({
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

    for (daravel.Middleware middleware in globalMiddlewares) {
      pipeline = pipeline.addMiddleware(middleware.handle());
    }

    final handler = pipeline.addHandler(rootRouter.call);

    // Use any available host or container IP (usually `0.0.0.0`).
    final ip = InternetAddress.anyIPv4;
    final server = await serve(handler, ip, port);

    // ignore: avoid_print
    print('Server listening on port ${server.port}');

    return server;
  }
}
