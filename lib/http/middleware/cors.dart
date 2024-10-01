import 'package:daravel_core/http/middleware/middleware.dart';
import 'package:shelf/shelf.dart';

// TODO: Test
class CorsMiddleware implements DaravelMiddleware {
  final List methods;
  final dynamic origin;

  CorsMiddleware({
    this.origin,
    this.methods = const ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  });

  @override
  Middleware handle() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Check if the origin is allowed
        if (origin is String && origin != '*') {
          if (request.headers['origin'] != origin) {
            return Response.forbidden('Origin not allowed');
          }
        } else if (origin is List &&
            !origin.contains(request.headers['origin'])) {
          return Response.forbidden('Origin not allowed');
        }

        String matchedOrigin =
            origin is String ? origin : request.headers['origin'];

        // Handle the request
        if (request.method == 'OPTIONS') {
          // Handle preflight CORS requests
          return Response.ok('', headers: _corsHeaders(matchedOrigin, methods));
        }

        // Get the actual response from the handler
        final Response response = await innerHandler(request);

        // Add CORS headers to the response
        return response.change(headers: _corsHeaders(matchedOrigin, methods));
      };
    };
  }

  /// Define the CORS headers
  Map<String, String> _corsHeaders(String origin, List methods) {
    return {
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Methods': methods.join(', '),
      'Access-Control-Allow-Headers':
          'Origin, Content-Type, X-Requested-With, Accept',
    };
  }
}
