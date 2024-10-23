import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:daravel_core/console/logger.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'generate.dart';

class CreateCommand extends Command {
  @override
  String get description => "Create a new Daravel project";

  @override
  String get name => "create";

  static final Directory _cacheDir =
      Directory(path.join(_homeDirectory, ".daravel"));

  final File _projectTemplateFile =
      File(path.join(_cacheDir.path, "project_template.zip"));

  final File _projectTemplateFileInfo =
      File(path.join(_cacheDir.path, "project_template.zip.json"));

  late final Logger logger = Logger();

  CreateCommand() {
    argParser.addOption(
      "project-name",
      abbr: "p",
      help: "The name of the project to create",
      mandatory: true,
    );
  }

  @override
  Future<void> run([String? createPath, String? overrideName]) async {
    try {
      await _checkForTemplateReleaseUpdate();
    } catch (error) {
      if (!_projectTemplateFile.existsSync()) {
        logger.error("Failed to fetch project template");
        return;
      }
    }

    final projectName = (argResults!.rest.isNotEmpty
            ? argResults!.rest.first
            : argResults!["project-name"]) ??
        overrideName;
    if (projectName == null) {
      logger.warning("Please provide a project name");
      return;
    }

    final projectPath =
        path.join(createPath ?? Directory.current.path, projectName);

    if (Directory(projectPath).existsSync()) {
      logger.warning("Directory $projectName already exists");
      return;
    }

    Directory(projectPath).createSync();

    final bytes = _projectTemplateFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    String? rootDir;

    for (final file in archive) {
      if (file.isFile) continue;
      rootDir = file.name;
      break;
    }

    if (rootDir == null) {
      logger.error('Project template file is invalid');
      return;
    }

    for (final file in archive) {
      if (file.name.startsWith(rootDir)) {
        final relativePath = file.name.substring(rootDir.length);
        if (relativePath.isEmpty) continue;
        final filePath = '$projectPath/$relativePath';
        if (file.isFile) {
          final outFile = File(filePath);
          outFile.parent.createSync(recursive: true);
          outFile.writeAsBytesSync(file.content as List<int>);
        } else {
          Directory(filePath).create(recursive: true);
        }
      }
    }

    // Clean Up & Generate Codes.
    Directory(path.join(projectPath, '.vscode')).deleteSync(recursive: true);

    logger.info("Running generate command...");

    await GenerateCommand().run(projectPath);

    logger.success("Project $projectName created!");
  }

  Future<void> _checkForTemplateReleaseUpdate() async {
    if (!_cacheDir.existsSync()) {
      _cacheDir.createSync();
    }

    final gitHubApiUrl =
        'https://api.github.com/repos/dart-daravel/daravel-starter/releases/latest';

    final response = await http.get(Uri.parse(gitHubApiUrl));

    Map<String, dynamic>? releaseData;

    if (response.statusCode == 200) {
      releaseData = json.decode(response.body);
    }

    final info = _projectTemplateFileInfo.existsSync()
        ? json.decode(_projectTemplateFileInfo.readAsStringSync())
        : {};

    final remoteVersion = Version.parse(
        (releaseData?['tag_name']?.toString() ?? '0.0.0')
            .replaceFirst('v', ''));
    final localVersion =
        Version.parse(info['version']?.replaceFirst('v', '') ?? '0.0.0');

    if (!_projectTemplateFileInfo.existsSync() ||
        !_projectTemplateFile.existsSync() ||
        remoteVersion > localVersion ||
        !await _checkSumMatch(_projectTemplateFile, info)) {
      await _downloadTemplateRelease(releaseData);
    }
  }

  Future<bool> _checkSumMatch(File file, Map<String, dynamic> info) async {
    final fileBytes = await file.readAsBytes();

    return info['checksum'] == md5.convert(fileBytes).toString();
  }

  static String get _homeDirectory =>
      Platform.environment["HOME"] ?? Platform.environment['USERPROFILE'] ?? "";

  Future<void> _downloadTemplateRelease(
      Map<String, dynamic>? releaseData) async {
    if (releaseData == null) {
      return;
    }

    final downloadUrl = releaseData['zipball_url'];

    final downloadResponse = await http.get(Uri.parse(downloadUrl));

    if (downloadResponse.statusCode == 200) {
      await _projectTemplateFile.writeAsBytes(downloadResponse.bodyBytes);
      _projectTemplateFileInfo.writeAsStringSync(
          json.encode({
            'checksum': md5.convert(downloadResponse.bodyBytes).toString(),
            'url': downloadUrl,
            'version': releaseData['tag_name'],
          }),
          mode: FileMode.writeOnly);
      logger.info('Fetched project template');
    }
  }
}
