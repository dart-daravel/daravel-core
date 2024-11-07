import 'package:daravel_core/http/resources/json/json_resource_parser.dart';

class JsonResource<T> extends JsonResourceParser {
  T data;

  @override
  List<String> get hidden => [];

  JsonResource(this.data);

  @override
  int get statusCode => 200;

  @override
  Map toJson() {
    return const {};
  }
}
