import 'dart:convert';

import 'package:shelf/shelf.dart';

abstract class JsonResourceParser {
  List<String> get hidden => []; // ignore: coverage

  int get statusCode => 200; // ignore: coverage

  Object toJson();

  Object parseJson() {
    Object json = toJson();
    if (json is Map) {
      _parseMap(json);
    } else if (json is List) {
      if (json.isNotEmpty && json.first is! Map) {
        json = json.map((e) => e.toJson()).toList();
      }
      for (var i = 0; i < json.length; i++) {
        _parseMap(json[i]);
      }
    }
    return json;
  }

  void _parseMap(Map json) {
    for (final key in hidden) {
      if (key.contains('.')) {
        final keys = key.split('.');
        var map = json;
        for (var i = 0; i < keys.length - 1; i++) {
          if (!map.containsKey(keys[i])) {
            break;
          }
          map = map[keys[i]];
        }
        if (!map.containsKey(keys.last)) {
          continue;
        }
        map.remove(keys.last);
      } else {
        json.remove(key);
      }
    }
  }

  Response toJsonResponse() {
    return Response(
      statusCode,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(parseJson()),
    );
  }
}
