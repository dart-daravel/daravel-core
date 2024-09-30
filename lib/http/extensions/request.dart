import 'dart:convert';

import 'package:shelf/shelf.dart';

extension RequestExtension on Request {
  /// Get the JSON payload of the request.
  Future<Map<String, dynamic>> json() async {
    try {
      // Attempt to decode response body.
      return jsonDecode(await readAsString());
    } catch (error) {
      // Throw exception if content-type was expected to be application/json.
      if (headers['content-type'] == 'application/json') {
        rethrow;
      }
      return {};
    }
  }
}
