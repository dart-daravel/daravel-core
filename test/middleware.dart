import 'package:daravel_core/daravel_core.dart';
import 'package:shelf/shelf.dart';

class TestMiddleware implements DaravelMiddleware {
  @override
  Middleware handle() {
    return (Handler innerHandler) {
      return (Request request) async {
        final Response response = await innerHandler(request);
        return response.change(headers: {
          'X-Test-Middleware': 'true',
        });
      };
    };
  }
}
