import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;

import 'package:daravel_core/console/commands/new.dart';
import 'package:daravel_core/console/commands/generate.dart';
import 'package:daravel_core/console/commands/make_config.dart';

void main() {
  tearDown(() {
    Directory(path.join(Directory.current.path, 'test/playground'))
        .deleteSync(recursive: true);
  });

  test('Code generation test', () async {
    final logs = <String>[];

    // Prepare
    final playgroundDirectory =
        Directory(path.join(Directory.current.path, 'test/playground'));

    if (!playgroundDirectory.existsSync()) {
      playgroundDirectory.createSync();
    }

    final playgroundConfigDirectory =
        Directory(path.join(playgroundDirectory.path, 'config'));
    final playgroundModelDirectory =
        Directory(path.join(playgroundDirectory.path, 'app/models'));

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

    expect(logs, ['\x1B[31m[ERROR] \x1B[37mConfig directory not found.']);
    logs.clear();

    if (!playgroundConfigDirectory.existsSync()) {
      playgroundConfigDirectory.createSync();
    }

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

    expect(logs, ['\x1B[31m[ERROR] \x1B[37mModels directory not found.']);
    logs.clear();

    if (!playgroundModelDirectory.existsSync()) {
      playgroundModelDirectory.createSync(recursive: true);
    }

    final configDirectory =
        Directory(path.join(Directory.current.path, 'example/config'));

    final modelsDirectory =
        Directory(path.join(Directory.current.path, 'example/app/models'));

    // Copy config files from example directory
    await for (var entity in configDirectory.list(recursive: false)) {
      var newFile = File(
          '${playgroundConfigDirectory.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}');
      await newFile.writeAsString(await (entity as File).readAsString(),
          mode: FileMode.writeOnly);
    }

    // Copy models from example directory
    await for (var entity in modelsDirectory.list(recursive: false)) {
      var newFile = File(
          '${playgroundModelDirectory.path}${Platform.pathSeparator}${entity.uri.pathSegments.last}');
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

    // Verify generated config map file.
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

    // Verify generated model map file.
    final generatedModelFile =
        File(path.join(playgroundBootstrapDirectory.path, 'models.dart'));

    expect(generatedModelFile.existsSync(), true);

    String generatedModelsFileContent = await generatedModelFile.readAsString();

    expect(
        generatedModelsFileContent.contains('// Generated code, do not modify'),
        true);

    expect(
        generatedModelsFileContent
            .contains("import '../app/models/user.dart';"),
        true);

    expect(generatedModelsFileContent.contains('final user = User();'), true);

    expect(
        generatedModelsFileContent
            .contains('final Map<Type, ORM> models = {};'),
        true);

    expect(generatedModelsFileContent.contains('void bootModels() {'), true);

    expect(generatedModelsFileContent.contains('models[User] = User();'), true);

    expect(generatedModelsFileContent.contains('}'), true);
  });

  test('Create project test', () async {
    final logs = <String>[];

    // Prepare
    final playgroundDirectory =
        Directory(path.join(Directory.current.path, 'test/playground'));

    if (!playgroundDirectory.existsSync()) {
      playgroundDirectory.createSync();
    }

    await NewCommand().run(playgroundDirectory.path, 'test_project');

    final projectDirectory =
        Directory(path.join(playgroundDirectory.path, 'test_project'));

    expect(projectDirectory.existsSync(), true);
    expect(File(path.join(projectDirectory.path, 'pubspec.yaml')).existsSync(),
        true);

    await runZonedGuarded(
      () async {
        await NewCommand().run(playgroundDirectory.path, 'test_project');
      },
      (e, s) {},
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(logs,
        ['\x1B[33m[WARNING] \x1B[37mDirectory test_project already exists']);
    logs.clear();

    await runZonedGuarded(
      () async {
        await NewCommand().run(
          playgroundDirectory.path,
        );
      },
      (e, s) {},
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(logs, ['\x1B[33m[WARNING] \x1B[37mPlease provide a project name']);
  });

  test('Generate Config File', () async {
    final logs = <String>[];

    // Prepare
    final playgroundDirectory =
        Directory(path.join(Directory.current.path, 'test/playground'));

    if (!playgroundDirectory.existsSync()) {
      playgroundDirectory.createSync();
    }

    await NewCommand()
        .run(playgroundDirectory.path, 'make_config_test_project');

    final projectDirectory = Directory(
        path.join(playgroundDirectory.path, 'make_config_test_project'));

    expect(projectDirectory.existsSync(), true);
    expect(File(path.join(projectDirectory.path, 'pubspec.yaml')).existsSync(),
        true);

    await MakeConfigCommand().run(projectDirectory.path, 'Redis');

    expect(
        File(path.join(projectDirectory.path, 'config/redis.dart'))
            .existsSync(),
        true);

    await NewCommand()
        .run(playgroundDirectory.path, 'error_make_config_test_project');

    await runZonedGuarded(
      () async {
        await MakeConfigCommand().run(
          path.join(projectDirectory.path),
        );
      },
      (e, s) {},
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(logs, ['\x1B[31m[ERROR] \x1B[37mPlease provide config file name.']);
    logs.clear();

    await runZonedGuarded(
      () async {
        await MakeConfigCommand()
            .run(path.join(playgroundDirectory.path), 'JWT');
      },
      (e, s) {},
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    expect(logs, ['\x1B[31m[ERROR] \x1B[37mConfig directory not found.']);
  });
}
