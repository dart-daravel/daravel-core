import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:args/command_runner.dart';
import 'package:daravel_core/console/console_logger.dart';
import 'package:daravel_core/extensions/string.dart';
import 'package:path/path.dart' as path;

class GenerateCommand extends Command {
  @override
  String get description => 'Generates the project config map file';

  @override
  String get name => 'generate';

  late final ConsoleLogger logger = ConsoleLogger();

  @override
  Future<void> run([String? rootPath]) async {
    final configDirectory = Directory(path.join(rootPath ?? '', 'config'));
    final modelsDirectory = Directory(path.join(rootPath ?? '', 'app/models'));

    final configMapCodeBuilder = _ConfigMapCodeBuilder();
    final modelMapCodeBuilder = _ModelMapCodeBuilder();

    if (!configDirectory.existsSync()) {
      logger.error('Config directory not found.');
      return;
    }

    if (!modelsDirectory.existsSync()) {
      logger.error('Models directory not found.');
      return;
    }

    final File configMapFile =
        File(path.join(rootPath ?? '', 'bootstrap/config.dart'));

    final File modelMapFile =
        File(path.join(rootPath ?? '', 'bootstrap/models.dart'));

    try {
      await for (var entity in configDirectory.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final result = parseFile(
              path: entity.path,
              featureSet: FeatureSet.latestLanguageVersion());
          final visitor = _ConfigClassVisitor(
              entity.path.split(Platform.pathSeparator).last,
              configMapCodeBuilder);
          result.unit.visitChildren(visitor);
        }
      }

      await for (var entity in modelsDirectory.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final result = parseFile(
              path: entity.path,
              featureSet: FeatureSet.latestLanguageVersion());
          final visitor = _ModelClassVisitor(
              entity.path.split(Platform.pathSeparator).last,
              modelMapCodeBuilder);
          result.unit.visitChildren(visitor);
        }
      }

      configMapFile.writeAsStringSync(configMapCodeBuilder.build(),
          mode: FileMode.writeOnly);

      modelMapFile.writeAsStringSync(modelMapCodeBuilder.build(),
          mode: FileMode.writeOnly);

      logger.success("Done generating files.");
    } catch (e) {
      logger.error(
          "The was an error while generating the config map file, this is likely due to syntax errors in one of the concerned files.");
    }
  }
}

class _ConfigClassVisitor extends RecursiveAstVisitor<void> {
  final _ConfigMapCodeBuilder configMapCodeBuilder;
  final String fileName;

  _ConfigClassVisitor(this.fileName, this.configMapCodeBuilder);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    for (var metadata in node.metadata) {
      if (metadata.name.name == 'Config') {
        List<String> fields = [];
        for (var member in node.members) {
          if (member is FieldDeclaration) {
            for (var field in member.fields.variables) {
              fields.add(field.name.toString());
            }
          }
        }
        if (fields.isEmpty) {
          continue;
        }
        configMapCodeBuilder.addConfigClass(
            fileName, node.name.toString(), fields);
      }
    }

    super.visitClassDeclaration(node);
  }
}

class _ModelClassVisitor extends RecursiveAstVisitor<void> {
  final _ModelMapCodeBuilder modelMapCodeBuilder;
  final String fileName;

  _ModelClassVisitor(this.fileName, this.modelMapCodeBuilder);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    for (var metadata in node.metadata) {
      if (metadata.name.name == 'OrmModel') {
        modelMapCodeBuilder.addModelClass(fileName, node.name.toString());
      }
    }

    super.visitClassDeclaration(node);
  }
}

class _ConfigClass {
  final String className;
  final String fileName;
  final List<String> fields;

  _ConfigClass(this.fileName, this.className, this.fields);
}

class _ModelClass {
  final String className;
  final String fileName;

  _ModelClass(this.fileName, this.className);
}

class _ConfigMapCodeBuilder {
  final List<_ConfigClass> _configClasses = [];

  _ConfigMapCodeBuilder();

  void addConfigClass(String fileName, String name, List<String> fields) {
    _configClasses.add(_ConfigClass(fileName, name, fields));
  }

  String build() {
    final importsSection = StringBuffer();
    final initializationSection = StringBuffer();
    final assignmentSection = StringBuffer();
    final codeBuffer = StringBuffer();

    assignmentSection.writeln("final Map<String, dynamic> config = {};");
    assignmentSection.writeln();
    assignmentSection.writeln("void bootConfig() {");

    for (var configClass in _configClasses) {
      importsSection.writeln("import '../config/${configClass.fileName}';");
      initializationSection.writeln(
          "final ${configClass.className.toLowerCase()} = ${configClass.className}();");
      for (var field in configClass.fields) {
        assignmentSection.writeln(
            "  config['${configClass.className.toLowerCase()}.$field'] = ${configClass.className.toLowerCase()}.$field;");
      }
    }

    assignmentSection.writeln("}");

    codeBuffer.writeln('// Generated code, do not modify');
    codeBuffer.writeln();
    codeBuffer.writeln(importsSection);
    codeBuffer.writeln(initializationSection);
    codeBuffer.writeln(assignmentSection);

    return codeBuffer.toString();
  }
}

class _ModelMapCodeBuilder {
  final List<_ModelClass> _modelClasses = [];

  _ModelMapCodeBuilder();

  void addModelClass(String fileName, String name) {
    _modelClasses.add(_ModelClass(fileName, name));
  }

  String build() {
    final importsSection = StringBuffer();
    final initializationSection = StringBuffer();
    final assignmentSection = StringBuffer();
    final codeBuffer = StringBuffer();

    importsSection
        .writeln("import 'package:daravel_core/database/orm/orm.dart';");

    assignmentSection.writeln("final Map<Type, ORM> models = {};");
    assignmentSection.writeln();
    assignmentSection.writeln("void bootModels() {");

    for (var modelClass in _modelClasses) {
      importsSection.writeln("import '../app/models/${modelClass.fileName}';");
      initializationSection.writeln(
          "final ${modelClass.className.camelCase()} = ${modelClass.className}();");
      assignmentSection.writeln(
          "  models[${modelClass.className}] = ${modelClass.className}();");
    }

    assignmentSection.writeln("}");

    codeBuffer.writeln('// Generated code, do not modify');
    codeBuffer.writeln();
    codeBuffer.writeln(importsSection);
    codeBuffer.writeln(initializationSection);
    codeBuffer.writeln(assignmentSection);

    return codeBuffer.toString();
  }
}
