import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../../resources/views/welcome.html.dart';
import 'controller.dart';

class TestController extends Controller {
  Response api(Request req) {
    return Response.ok(jsonEncode({
      'message': 'Hello, World!',
    }));
  }

  Response web(Request req) {
    return Response.ok(
      welcome(),
      headers: {'Content-Type': 'text/html'},
    );
  }

  Response echo(Request req, String echoMessage) {
    return Response.ok(jsonEncode({'message': echoMessage}));
  }
}
