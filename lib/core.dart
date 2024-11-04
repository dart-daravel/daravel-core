import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:daravel_core/daravel_core.dart';

class Core {
  final List<DaravelRouter> routers;
  final List<DaravelMiddleware> globalMiddlewares;
  final Map<String, dynamic> configMap;

  late final _env = DotEnv(includePlatformEnvironment: true)..load();

  late final Function(Core)? boot;
  late final Function(Object)? onBootError;

  Handler? _rootHandler;

  Core({
    this.routers = const [],
    this.globalMiddlewares = const [],
    this.configMap = const {},
    this.boot,
    this.onBootError,
  }) {
    try {
      boot?.call(this);
    } catch (e) {
      if (!onBootError?.call(e)) {
        rethrow;
      }
    }
  }

  Future<HttpServer> run({int? port}) async {
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
    final server = await serve(
      _rootHandler!,
      ip,
      int.tryParse(Platform.environment['PORT'] ?? '') ??
          port ??
          int.tryParse(_env['APP_PORT'] ?? '') ??
          8080,
    );

    // ignore: avoid_print
    print('Server listening on port ${server.port}');

    return server;
  }

  Handler? get rootHandler => _rootHandler;

  String? env(String key) => _env[key];

  String? config(String key) => configMap[key];
}
