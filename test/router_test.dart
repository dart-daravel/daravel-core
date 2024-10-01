import 'package:daravel_core/http/daravel_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelf/shelf.dart';

void main() {
  test('Top level routes', () {
    final router = DaravelRouter();
    router.get('/', (Request request) => Response.ok('Hello, World!'));
    router.get('/<name>',
        (Request request, String name) => Response.ok('Hello, $name!'));
    expect(router.routes.length, 2);
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
