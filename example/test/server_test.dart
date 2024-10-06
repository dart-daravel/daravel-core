import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'main.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Root', () async {
    final response = await get(Uri.parse('$host/v1'));
    expect(response.statusCode, 200);
    expect(
      response.body,
      jsonEncode({
        'message': 'Hello, World!',
      }),
    );
  });

  test('Echo', () async {
    final response = await get(Uri.parse('$host/v1/echo/hello'));
    expect(response.statusCode, 200);
    expect(
      response.body,
      jsonEncode({
        'message': 'hello',
      }),
    );
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
