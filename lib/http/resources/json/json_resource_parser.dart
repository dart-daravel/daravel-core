import 'dart:convert';

import 'package:daravel_core/http/resources/json/json_resource.dart';
import 'package:shelf/shelf.dart';

abstract class JsonResourceParser {
  List<String> get hidden;

  int get statusCode;

  Map toJson();

  Map parse() {
    final json = toJson();
    for (final key in hidden) {
      if (key.contains('.')) {
        final keys = key.split('.');
        var map = json;
        for (var i = 0; i < keys.length - 1; i++) {
          map = map[keys[i]];
        }
        switch (keys.last) {
          case '{first}':
            map.remove(map.keys.first);
            break;
          case '{last}':
            map.remove(map.keys.last);
            break;
          default:
            map.remove(keys.last);
        }
      } else {
        json.remove(key);
      }
    }
    return json;
  }

  Response toJsonResponse() {
    return Response(
      statusCode,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(parse()),
    );
  }

  static Response listToJsonResponse(int statusCode, List<Object> list) {
    return Response(
      statusCode,
      body: list.map((e) => JsonResource(e)).toList(),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
