import 'package:daravel_core/daravel_core.dart';
import 'package:daravel_core/globals.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';
import 'package:http/http.dart';

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';

  tearDown(() {
    locator.reset();
  });

  test('Test serve command', () async {
    final router = DaravelRouter();
    router.get(
        '/', (shelf.Request request) => shelf.Response.ok('Hello, World!'));

    final app = Core(
      routers: [router],
    );

    final serveCommand = ServeCommand(app);

    expect(serveCommand.name, 'serve');
    expect(serveCommand.description, 'Generates the project config map file');

    await serveCommand.run();

    final response = await get(Uri.parse('$host/'));
    expect(response.statusCode, 200);
    expect(response.body, 'Hello, World!');
  });
}
