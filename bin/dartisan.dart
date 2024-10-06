import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import './src/commands/generate.dart';

void main(List<String> args) async {
  final commandRunner = CommandRunner("dartisan", "The CLI tool for Daravel")
    ..addCommand(GenerateCommand());

  if (commandRunner.parse(args).command == null &&
      File('main.dart').existsSync()) {
    await passExecutionToDaravelProject(path.absolute('main.dart'), args);
    return;
  }

  commandRunner.run(args);
}

Future<void> passExecutionToDaravelProject(
    String filePath, List<String> args) async {
  var receivePort = ReceivePort();

  await Isolate.spawnUri(
    Uri.file(filePath),
    args,
    receivePort.sendPort,
  );

  await for (var message in receivePort) {
    if (message == null) {
      receivePort.close();
      break;
    }
  }
}
