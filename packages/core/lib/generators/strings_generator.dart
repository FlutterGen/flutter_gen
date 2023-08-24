import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/generators/strings_yaml.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/settings/string_path.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

String generateStrings(File pubspecFile,
    DartFormatter formatter,
    FlutterGenStrings stringsConfig,
) {
  if (stringsConfig.inputs.isEmpty) {
    throw const InvalidSettingsException('The value of "flutter_gen/strings" is incorrect.');
  }

  final buffer = StringBuffer();
  final className = stringsConfig.outputs.className;
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln();
  buffer.writeln('class $className {');
  buffer.writeln('$className._();');
  buffer.writeln();

  final rawStringMap = <String, String>{};

  stringsConfig.inputs.map((file) => StringPath(join(pubspecFile.parent.path, file))).forEach((stringFile) {
    print('\n\nstringFile.file.path -> ${stringFile.file.path}, stringFile.mime -> ${stringFile.mime}');
    print(
        'stringFile.isYaml -> ${stringFile.isYaml}, stringFile.isJson -> ${stringFile.isJson}, stringFile.isCsv -> ${stringFile.isCsv}\n\n');
    if (stringFile.isYaml) {
      // TODO(brads): add type (camel-case, dot-delimited, etc. support)
      rawStringMap.addAll(StringsYaml.fromJson(loadYaml(stringFile.file.readAsStringSync())).strings);
      print('rawStringMap.strings -> $rawStringMap');
    }
  });

  final stringList = <_String>[];
  if (stringsConfig.outputs.isCamelCaseStyle) {
    rawStringMap.forEach((key, value) {
      stringList.add(_String(key, key.camelCase(), value));
    });
  }
  print('stringList -> $stringList');

  stringList
      .distinctBy((string) => string.name)
      .sortedBy((string) => string.name)
      .forEach((string) => buffer.write(string.asStringStatement()));

  buffer.writeln('}');
  print(buffer.toString());
  return formatter.format(buffer.toString());
}

class _String {
  _String(this.rawName, this.name, this.value);

  final String rawName;
  final String name;
  final String value;

  String asStringStatement() {
    final buffer = StringBuffer();
    //                                                             (blank line)
    //   /// com-scan-system-manager: System Manager               (comment line)
    //   final String comScanSystemManager = 'System Manager';     (string var. def. line)

    final String escapedValue = value.replaceAll("'", r"\'");

    buffer.writeln('');
    // generate the comment line
    buffer.writeln('/// $rawName: $value');
    buffer.writeln('static const String $name = \'$escapedValue\';');

    return buffer.toString();
  }
}
