import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:daravel_core/console/commands/make_model.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/commands/generate.dart';
import 'package:daravel_core/console/commands/new.dart';
import 'package:daravel_core/console/commands/make_config.dart';

void main(List<String> args) async {
  final commandRunner = CommandRunner("dartisan", "The CLI tool for Daravel")
    ..addCommand(NewCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(MakeConfigCommand())
    ..addCommand(MakeModelCommand());

  if (commandRunner.parse(args).command == null &&
      File('main.dart').existsSync()) {
    await passExecutionToDaravelProject(
        path.absolute('main.dart'), args, commandRunner);
    return;
  }

  commandRunner.run(args);
}

Future<void> passExecutionToDaravelProject(
    String filePath, List<String> args, CommandRunner commandRunner) async {
  var receivePort = ReceivePort();

  await Isolate.spawnUri(
    Uri.file(filePath),
    args,
    receivePort.sendPort,
  );

  await for (var message in receivePort) {
    if (message == null) {
      commandRunner.printUsage();
      receivePort.close();
      break;
    } else if (message == -1) {
      receivePort.close();
      break;
    }
  }
}
