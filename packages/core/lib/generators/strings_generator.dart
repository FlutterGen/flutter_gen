import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/settings/string_path.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:path/path.dart';

String generateStrings(
  File pubspecFile,
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

  stringsConfig.inputs.map((file) => StringPath(join(pubspecFile.parent.path, file)))
  .forEach((stringFile) {
    print('\n\nstringFile.file.path -> ${stringFile.file.path}, stringFile.mime -> ${stringFile.mime}');
    print('stringFile.isYaml -> ${stringFile.isYaml}, stringFile.isJson -> ${stringFile.isJson}, stringFile.isCsv -> ${stringFile.isCsv}\n\n');
  });

  buffer.writeln('}');
  print(buffer.toString());
  return formatter.format(buffer.toString());
}

// class _String {
//   _String(this.name, this.value);
//
//   final String name;
//   final String value;
// }
