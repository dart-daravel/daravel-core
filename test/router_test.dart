import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

import 'package:daravel_core/daravel_core.dart';

void main() {
  final host = 'http://localhost:8080';
  test('Top level routes', () async {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.get('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        LoggerMiddleware(),
      ],
    );

    expect(router.routes.length, 2);
    expect(router.routes[0].method, 'GET');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/<name>');

    await app.run();

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host/')));

    expect(response.statusCode, 200);
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host/John')));

    expect(response2.statusCode, 200);
    expect(await response2.readAsString(), 'Hello, John!');
  });

  test('Post requests', () {
    final router = DaravelRouter();
    router.post('/', (Request request) => Response.ok('Hello, World!'));
    router.post('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    expect(router.routes.length, 2);
    expect(router.routes[0].method, 'POST');
    expect(router.routes[0].path, '/');
    expect(router.routes[1].path, '/<name>');
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
