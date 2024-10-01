import 'dart:io';

import 'package:daravel_core/daravel_core.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  const host = 'http://localhost:8081';
  test('CORS Middleware Test, Origin: *', () async {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.get('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        CorsMiddleware(),
      ],
    );

    final HttpServer server = await app.run(port: 8081);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host/')));

    expect(response.statusCode, 200);
    expect(response.headers['Access-Control-Allow-Origin'], '*');
    expect(response.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');
    expect(await response.readAsString(), 'Hello, World!');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host/John')));

    expect(response2.statusCode, 200);
    expect(response2.headers['Access-Control-Allow-Origin'], '*');
    expect(response2.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response2.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');
    expect(await response2.readAsString(), 'Hello, John!');

    final Response response3 =
        await app.rootHandler!(Request('OPTIONS', Uri.parse('$host/')));

    // Pre-Flight Request
    expect(response3.statusCode, 200);
    expect(response3.headers['Access-Control-Allow-Origin'], '*');
    expect(response3.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response3.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');

    await server.close();
  });

  test('CORS Middleware Test, Origin: app.enterprise.com', () async {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.get('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));

    final app = DaravelApp(
      routers: [router],
      globalMiddlewares: [
        CorsMiddleware(origin: 'app.enterprise.com'),
      ],
    );

    final HttpServer server = await app.run(port: 8081);

    final Response response =
        await app.rootHandler!(Request('GET', Uri.parse('$host/')));

    expect(response.statusCode, 403);
    expect(await response.readAsString(), 'Origin not allowed');

    final Response response2 =
        await app.rootHandler!(Request('GET', Uri.parse('$host/'), headers: {
      'origin': 'app.enterprise.com',
    }));

    expect(response2.statusCode, 200);
    expect(
        response2.headers['Access-Control-Allow-Origin'], 'app.enterprise.com');
    expect(response2.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response2.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');
    expect(await response2.readAsString(), 'Hello, World!');

    final Response response3 = await app
        .rootHandler!(Request('GET', Uri.parse('$host/John'), headers: {
      'origin': 'app.enterprise.com',
    }));

    expect(response3.statusCode, 200);
    expect(
        response3.headers['Access-Control-Allow-Origin'], 'app.enterprise.com');
    expect(response3.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response3.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');
    expect(await response3.readAsString(), 'Hello, John!');

    final Response response4 = await app
        .rootHandler!(Request('OPTIONS', Uri.parse('$host/'), headers: {
      'origin': 'app.enterprise.com',
    }));

    // Pre-Flight Request
    expect(response4.statusCode, 200);
    expect(
        response4.headers['Access-Control-Allow-Origin'], 'app.enterprise.com');
    expect(response4.headers['Access-Control-Allow-Methods'],
        'GET, POST, PUT, DELETE, OPTIONS');
    expect(response4.headers['Access-Control-Allow-Headers'],
        'Origin, Content-Type, X-Requested-With, Accept');
    expect(await response4.readAsString(), '');

    await server.close();
  });
}
