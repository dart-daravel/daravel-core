import 'package:args/command_runner.dart';
import 'package:daravel_core/core.dart';

class ServeCommand extends Command {
  final Core core;

  @override
  String get name => 'serve'; // ignore: coverage

  @override
  String get description =>
      'Generates the project config map file'; // ignore: coverage

  ServeCommand(this.core) {
    argParser.addOption('port', abbr: 'p');
  }

  @override
  Future<void> run() async {
    await core.run(port: int.tryParse(argResults?.option('port') ?? ''));
  }
}
