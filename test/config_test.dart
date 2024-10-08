import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  const host = 'http://localhost';
  test('Declared config value', () async {
    final router = DaravelRouter();
    late final Core app;

    router.get('/',
        (Request request) => Response.ok('Hello, ${app.config('app.name')}!'));

    app = Core(routers: [
      router
    ], globalMiddlewares: [
      CorsMiddleware(),
    ], configMap: {
      'app.name': 'Daravel',
    });

    final HttpServer server = await app.run(port: 8071);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8071/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, Daravel!');

    await server.close();
  });
}
