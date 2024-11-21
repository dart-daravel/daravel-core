import 'package:daravel_core/annotations/config.dart';

@Config()
class Session {
  String driver = 'file';
  String lifetime = '120';
  String path = 'storage/sessions';
  String cookie = 'daravel_session';
}
