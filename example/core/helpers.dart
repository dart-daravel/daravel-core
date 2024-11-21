import 'package:daravel_core/daravel_core.dart';
import '../bootstrap/app.dart';

Core app() => core;

dynamic env(String key, [dynamic defaultValue]) =>
    core.env(key) ?? defaultValue;
