import 'package:daravel_core/daravel_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';
import 'package:http/http.dart';

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';
  test('Test serve command', () async {
    final router = DaravelRouter();
    router.get(
        '/', (shelf.Request request) => shelf.Response.ok('Hello, World!'));

    final app = Core(
      routers: [router],
    );

    await ServeCommand(app).run();

    final response = await get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');
  });
}
