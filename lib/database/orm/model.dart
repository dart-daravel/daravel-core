import 'package:daravel_core/database/orm/orm.dart';

abstract class Model extends ORM {
  @override
  String? get connection => null;

  @override
  String? get table => null;
}
