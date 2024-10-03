import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'package:daravel_core/daravel_core.dart';

import 'middleware.dart';

void main() {
  const host = 'http://localhost';

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
        await app.rootHandler!(Request('GET', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8080/John/age/25')));

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
        await app.rootHandler!(Request('POST', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('POST', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('POST', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    await server.close();
  });

  test('Put requests', () async {
    final router = DaravelRouter();
    router.put('/', (Request request) => Response.ok('Hello, World!'));
    router.put('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.put(
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'PUT');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'PUT');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'PUT');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('PUT', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('PUT', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('PUT', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    await server.close();
  });

  test('Patch requests', () async {
    final router = DaravelRouter();
    router.patch('/', (Request request) => Response.ok('Hello, World!'));
    router.patch('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.patch(
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'PATCH');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'PATCH');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'PATCH');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('PATCH', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('PATCH', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('PATCH', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    await server.close();
  });

  test('Custom requests', () async {
    final router = DaravelRouter();
    router.add('GET', '/', (Request request) => Response.ok('Hello, World!'));
    router.add('POST', '/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.add(
        'PATCH',
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'GET');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'POST');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'PATCH');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run(port: 8084);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8084/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('POST', Uri.parse('$host:8084/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('PATCH', Uri.parse('$host:8084/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    final Response response4 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8084/John/age/25')));

    expect(response4.statusCode, 404);

    await server.close();
  });

  test('Head requests', () async {
    final router = DaravelRouter();
    router.head('/', (Request request) => Response.ok(''));
    router.head('/<name>', (Request request, String name) => Response.ok(''));
    router.head('/<name>/age/<age>',
        (Request request, String name, String age) => Response.ok(''));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'HEAD');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'HEAD');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'HEAD');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('HEAD', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), '');

    final Response response2 =
        await app.rootHandler!(Request('HEAD', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), '');

    final Response response3 = await app
        .rootHandler!(Request('HEAD', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(await response3.readAsString(), '');

    await server.close();
  });

  test('Options requests', () async {
    final router = DaravelRouter();
    router.options('/', (Request request) => Response.ok(''));
    router.options(
        '/<name>', (Request request, String name) => Response.ok(''));
    router.options('/<name>/age/<age>',
        (Request request, String name, String age) => Response.ok(''));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, 'OPTIONS');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, 'OPTIONS');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, 'OPTIONS');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    final Response response =
        await app.rootHandler!(Request('OPTIONS', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), '');

    final Response response2 = await app
        .rootHandler!(Request('OPTIONS', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), '');

    final Response response3 = await app
        .rootHandler!(Request('OPTIONS', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(await response3.readAsString(), '');

    await server.close();
  });

  test('Any requests', () async {
    final router = DaravelRouter();
    router.any('/', (Request request) => Response.ok('Hello, World!'));
    router.any('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    router.any(
        '/<name>/age/<age>',
        (Request request, String name, String age) =>
            Response.ok('Hello, $name! You are $age years old!'));

    expect(router.routes.length, 3);
    expect(router.routes[0].method, '');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].method, '');
    expect(router.routes[1].path, '/<name>');
    expect(router.routes[2].method, '');
    expect(router.routes[2].path, '/<name>/age/<age>');

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run();

    Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    response =
        await app.rootHandler!(Request('POST', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    response = await app.rootHandler!(Request('PUT', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    response =
        await app.rootHandler!(Request('DELETE', Uri.parse('$host:8080/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8080/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8080/John/age/25')));

    expect(response3.statusCode, 200);
    expect(
        await response3.readAsString(), 'Hello, John! You are 25 years old!');

    await server.close();
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

  test('Nested/Grouped routes', () async {
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

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    HttpServer server = await app.run(port: 8082);

    Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8082/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8082/v1')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    response = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8080/v1/echo/hello')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'hello');

    await server.close();
  });

  test('Middleware Logic Test', () async {
    final router = DaravelRouter();
    router
        .get('/', (Request request) => Response.ok('Hello, World!'))
        .middleware(TestMiddleware());

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run(port: 8083);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8083/')));

    expect(response.statusCode, 200);

    expect(response.headers['X-Test-Middleware'], 'true');
    expect(await response.readAsString(), 'Hello, World!');

    await server.close();
  });

  test('Domain Routing Test', () async {
    final router = DaravelRouter();
    final router2 = DaravelRouter();

    router.get(
        '/root-level', (Request request) => Response.ok('Hello, World!'));

    router.domain('app.enterprise.com').get('/', (Request request) {
      return Response.ok('Hello, World!');
    });

    router2.domain('app.dart.com').group('', (router) {
      router.get('/v1', (Request request) => Response.ok('Hello, World!'));
    });

    final app = DaravelApp(
      routers: [
        router,
        router2,
      ],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    final HttpServer server = await app.run(port: 8086);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8086/')));

    expect(response.statusCode, 404);

    final Response response2 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8086/root-level')));

    expect(response2.statusCode, 200);

    final Response response3 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8086/'), headers: {
      HttpHeaders.hostHeader: 'app.enterprise.com',
    }));

    expect(response3.statusCode, 200);
    expect(await response3.readAsString(), 'Hello, World!');

    final Response response4 = await app
        .rootHandler!(Request('GET', Uri.parse('$host:8086/v1'), headers: {
      HttpHeaders.hostHeader: 'app.dart.com',
    }));

    expect(response4.statusCode, 200);
    expect(await response4.readAsString(), 'Hello, World!');

    final Response response5 =
        await app.rootHandler!(Request('GET', Uri.parse('$host:8086/v1')));

    expect(response5.statusCode, 404);

    await server.close();
  });
}
