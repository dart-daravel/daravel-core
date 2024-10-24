import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/logger.dart';
import 'package:daravel_core/extensions/string.dart';

class MakeConfigCommand extends Command {
  @override
  String get description => 'Create a config file';

  @override
  String get name => 'make:config';

  late final Logger logger = Logger();

  String? configName;

  MakeConfigCommand() {
    argParser.addOption(
      "config-name",
      abbr: "n",
      help: "The name of the config file to create",
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

    final configFile = File(
        '${directory.path}${Platform.pathSeparator}${configName!.underscoreCase()}.dart');

    configFile.writeAsStringSync(template, mode: FileMode.writeOnly);

    logger.success(
        'Config file ${directory.path}${Platform.pathSeparator}${configName!.underscoreCase()}.dart created.');
  }

  String get template => '''
import 'package:daravel_core/daravel_core.dart';

@Config()
class ${configName!.ucfirst()} {

}
''';
}
