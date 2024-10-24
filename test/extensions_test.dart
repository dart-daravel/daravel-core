import 'package:daravel_core/daravel_core.dart';
import 'package:test/test.dart';

void main() {
  test('String: ucfirst', () async {
    expect('hello'.ucfirst(), 'Hello');
    expect('Hello'.ucfirst(), 'Hello');
    expect('HELLO'.ucfirst(), 'HELLO');
    expect('hELLO'.ucfirst(), 'HELLO');
  });

  test('String: underscoreCase', () async {
    expect('helloWorld'.underscoreCase(), 'hello_world');
    expect('HelloWorld'.underscoreCase(), 'hello_world');
    expect('HELLO_WORLD'.underscoreCase(), 'hello_world');
    expect('hello_world'.underscoreCase(), 'hello_world');
    expect('hello-world'.underscoreCase(), 'hello_world');
    expect('hello world'.underscoreCase(), 'hello_world');
    expect('helloWorld123'.underscoreCase(), 'hello_world123');
    expect('hello123World'.underscoreCase(), 'hello123_world');
    expect('hello 123 World'.underscoreCase(), 'hello_123_world');
  });
}
