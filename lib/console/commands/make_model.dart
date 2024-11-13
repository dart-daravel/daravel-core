import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:daravel_core/console/commands/generate.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/console_logger.dart';
import 'package:daravel_core/extensions/string.dart';

class MakeModelCommand extends Command {
  @override
  String get description => 'Create a Model file';

  @override
  String get name => 'make:model';

  late final ConsoleLogger logger = ConsoleLogger();

  String? modelName;

  MakeModelCommand() {
    argParser.addOption(
      "model-name",
      abbr: "n",
      help: "The name of the Model file to create",
      mandatory: true,
    );
  }

  @override
  Future<void> run([String? rootPath, String? overrideName]) async {
    final directory = Directory(path.join(rootPath ?? '', 'app/models'));

    if (!directory.existsSync()) {
      logger.error('app/models directory not found.');
      return;
    }

    modelName = (argResults?.rest.isNotEmpty ?? false)
        ? argResults?.rest.first
        : overrideName ?? argResults?["model-name"];

    final modelFile =
        File('${path.join(directory.path, modelName!.underscoreCase())}.dart');

    if (modelFile.existsSync()) {
      logger.error(
          'Model file ${path.join(directory.path, modelName!.underscoreCase())}.dart already exists.');
      return;
    }

    if (modelName == null) {
      logger.error('Please provide model file name.');
      return;
    }

    modelFile.writeAsStringSync(template, mode: FileMode.writeOnly);

    await GenerateCommand().run();

    logger.success(
        'Model file ${path.join(directory.path, modelName!.underscoreCase())}.dart created.');
  }

  String get template => '''
import 'package:daravel_core/daravel_core.dart';

@OrmModel()
class ${modelName!.classCase()} extends Model {
  @override
  Map<String, Function> get relationships => {};
}
''';
}
