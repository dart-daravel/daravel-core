import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:args/command_runner.dart';

class GenerateCommand extends Command {
  @override
  String get description => 'Generates the project config map file';

  @override
  String get name => 'generate';

  @override
  void run() async {
    final directory = Directory('config');

    final configMapCodeBuilder = _ConfigMapCodeBuilder();

    if (!await directory.exists()) {
      print('Config directory not found.');
      return;
    }

    final File configMapFile = File('bootstrap/config.dart');

    try {
      await for (var entity in directory.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          var result = parseFile(
              path: entity.path,
              featureSet: FeatureSet.latestLanguageVersion());
          var visitor = _ConfigClassVisitor(
              entity.path.split(Platform.pathSeparator).last,
              configMapCodeBuilder);
          result.unit.visitChildren(visitor);
        }
      }

      configMapFile.writeAsStringSync(configMapCodeBuilder.build(),
          mode: FileMode.writeOnly);
    } catch (e) {
      print(
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

class _ConfigClass {
  final String className;
  final String fileName;
  final List<String> fields;

  _ConfigClass(this.fileName, this.className, this.fields);
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
    codeBuffer.writeln(importsSection);
    codeBuffer.writeln(initializationSection);
    codeBuffer.writeln(assignmentSection);

    print(codeBuffer.toString());

    return codeBuffer.toString();
  }
}
