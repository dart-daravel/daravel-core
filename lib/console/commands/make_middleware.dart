import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/console_logger.dart';
import 'package:daravel_core/extensions/string.dart';

class MakeMiddlewareCommand extends Command {
  @override
  String get description => 'Create a Config file';

  @override
  String get name => 'make:middleware';

  late final ConsoleLogger logger = ConsoleLogger();

  String? middlewareName;

  MakeMiddlewareCommand() {
    argParser.addOption(
      "middleware-name",
      abbr: "n",
      help: "The name of the Middleware file to create",
      mandatory: true,
    );
  }

  @override
  Future<void> run([String? rootPath, String? overrideName]) async {
    final directory =
        Directory(path.join(rootPath ?? '', 'app/http/middleware'));

    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    middlewareName = (argResults?.rest.isNotEmpty ?? false)
        ? argResults?.rest.first
        : overrideName ?? argResults?["middleware-name"];

    if (middlewareName == null) {
      logger.error('Please provide middleware file name.');
      return;
    }

    final middlewareFile = File(
        '${path.join(directory.path, middlewareName!.underscoreCase())}.dart');

    middlewareFile.writeAsStringSync(template, mode: FileMode.writeOnly);

    logger.success(
        'Middleware file ${path.join(directory.path, middlewareName!.underscoreCase())}.dart created.');
  }

  String get template => '''
import 'package:daravel_core/daravel_core.dart';
import 'package:shelf/shelf.dart';

class ${middlewareName!.classCase()} implements DaravelMiddleware {
  @override
  Middleware handle() {
    return (Handler innerHandler) {
      return (Request request) async {
        
      }
    }
  }
}
''';
}
