import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;

import '../bin/src/commands/generate.dart';

void main() {
  tearDown(() {
    Directory(path.join(Directory.current.path, 'test/playground'))
        .deleteSync(recursive: true);
  });

  test('Code  generation test', () async {
    final logs = <String>[];

    // Prepare
    final playgroundDirectory =
        Directory(path.join(Directory.current.path, 'test/playground'));

    if (!playgroundDirectory.existsSync()) {
      playgroundDirectory.createSync();
    }

    final playgroundConfigDirectory =
        Directory(path.join(playgroundDirectory.path, 'config'));

    runZonedGuarded(
      () async {
        await GenerateCommand().run(playgroundDirectory.path);
      },
      (e, s) {},
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(logs, ['\x1B[31m', '[ERROR] Config directory not found.']);
    logs.clear();

    if (!playgroundConfigDirectory.existsSync()) {
      playgroundConfigDirectory.createSync();
    }

    final configDirectory =
        Directory(path.join(Directory.current.path, 'example/config'));

    await for (var entity in configDirectory.list(recursive: false)) {
      var newFile = File(
          '${playgroundConfigDirectory.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}');
      await newFile.writeAsString(await (entity as File).readAsString(),
          mode: FileMode.writeOnly);
    }

    final playgroundBootstrapDirectory =
        Directory(path.join(playgroundDirectory.path, 'bootstrap'));

    if (!playgroundBootstrapDirectory.existsSync()) {
      playgroundBootstrapDirectory.createSync();
    }

    final generateCommand = GenerateCommand();

    expect(generateCommand.name, 'generate');
    expect(
        generateCommand.description, 'Generates the project config map file');

    await generateCommand.run(playgroundDirectory.path);

    final generatedConfigFile =
        File(path.join(playgroundBootstrapDirectory.path, 'config.dart'));

    expect(generatedConfigFile.existsSync(), true);

    String generatedConfigFileContent =
        await generatedConfigFile.readAsString();

    expect(
        generatedConfigFileContent.contains('// Generated code, do not modify'),
        true);
    expect(
        generatedConfigFileContent.contains("import '../config/cache.dart';"),
        true);
    expect(generatedConfigFileContent.contains("import '../config/app.dart';"),
        true);

    expect(generatedConfigFileContent.contains('final session = Session();'),
        true);
    expect(generatedConfigFileContent.contains('final app = App();'), true);

    expect(
        generatedConfigFileContent
            .contains('final Map<String, dynamic> config = {};'),
        true);

    expect(generatedConfigFileContent.contains('void bootConfig() {'), true);
    expect(
        generatedConfigFileContent
            .contains("config['session.driver'] = session.driver;"),
        true);
    expect(
        generatedConfigFileContent
            .contains("config['session.lifetime'] = session.lifetime;"),
        true);
    expect(
        generatedConfigFileContent
            .contains("config['session.path'] = session.path;"),
        true);
    expect(
        generatedConfigFileContent
            .contains("config['session.cookie'] = session.cookie;"),
        true);
    expect(
        generatedConfigFileContent.contains("config['app.name'] = app.name;"),
        true);
    expect(generatedConfigFileContent.contains('}'), true);
  });
}
