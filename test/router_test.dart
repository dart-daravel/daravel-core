import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:daravel_core/daravel_core.dart';
import 'package:test/test.dart';

void main() {
  const host = 'http://localhost:8080';

  test('Top level routes', () async {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.get('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.get(
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'GET');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'GET');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'GET');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 =
        await app.rootHandler!(Request('GET', Uri.parse('$host/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    await server.close();
  });

  test('Post requests', () async {
    final router = DaravelRouter();
    router.post('/', (Request request) => Response.ok('Hello, World!'));
    router.post('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.post(
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'POST');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'POST');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'POST');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('POST', Uri.parse('$host/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('POST', Uri.parse('$host/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    await server.close();
  });

  test('Put requests', () {
    final router = DaravelRouter();
    router.put('/', (Request request) => Response.ok('Hello, World!'));
    router.put('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    expect(router.routes.length, 2);
    expect(router.routes[0].method, 'PUT');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/<name>');
  });

  test('Patch requests', () {
    final router = DaravelRouter();
    router.patch('/', (Request request) => Response.ok('Hello, World!'));
    router.patch('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    expect(router.routes.length, 2);
    expect(router.routes[0].method, 'PATCH');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/<name>');
  });

  test('Delete requests', () {
    final router = DaravelRouter();
    router.delete('/', (Request request) => Response.ok('Hello, World!'));
    router.delete('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    expect(router.routes.length, 2);
    expect(router.routes[0].method, 'DELETE');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/<name>');
  });

  test('Nested routes Level 1', () {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.group('/v1', (router) {
      router.get('/', (Request request) => Response.ok('Hello, World!'));
      router.get('/echo/<message>',
          (Request request, String message) => Response.ok(message));
    });
    expect(router.routes.length, 2);
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/v1');
    expect(router.routes[1].routes.length, 2);
    expect(router.routes[1].routes[0].path, '/');
    expect(router.routes[1].routes[1].path, '/echo/<message>');
  });
}
