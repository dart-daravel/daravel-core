import 'package:daravel_core/http/resources/json/json_resource_parser.dart';

class JsonResource<T> extends JsonResourceParser {
  T data;

  JsonResource(this.data);

  @override
  Object toJson() {
    return const {};
  }
}
