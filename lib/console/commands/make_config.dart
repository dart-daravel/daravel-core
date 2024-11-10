import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/console_logger.dart';
import 'package:daravel_core/extensions/string.dart';

class MakeConfigCommand extends Command {
  @override
  String get description => 'Create a Config file';

  @override
  String get name => 'make:config';

  late final ConsoleLogger logger = ConsoleLogger();

  String? configName;

  MakeConfigCommand() {
    argParser.addOption(
      "config-name",
      abbr: "n",
      help: "The name of the Config file to create",
      mandatory: true,
    );
  }

  @override
  Future<void> run([String? rootPath, String? overrideName]) async {
    final directory = Directory(path.join(rootPath ?? '', 'config'));

    if (!directory.existsSync()) {
      logger.error('Config directory not found.');
      return;
    }

    configName = (argResults?.rest.isNotEmpty ?? false)
        ? argResults?.rest.first
        : overrideName ?? argResults?["config-name"];

    if (configName == null) {
      logger.error('Please provide config file name.');
      return;
    }

    final configFile =
        File('${path.join(directory.path, configName!.underscoreCase())}.dart');

    configFile.writeAsStringSync(template, mode: FileMode.writeOnly);

    logger.success(
        'Config file ${path.join(directory.path, configName!.underscoreCase())}.dart created.');
  }

  String get template => '''
import 'package:daravel_core/daravel_core.dart';

@Config()
class ${configName!.classCase()} {

}
''';
}
