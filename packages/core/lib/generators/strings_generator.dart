import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';
import '../settings/pubspec.dart';
import '../settings/string_path.dart';
import '../utils/error.dart';
import 'generator_helper.dart';

String generateStrings(
  File pubspecFile,
  DartFormatter formatter,
  FlutterGenStrings strings,
) {
  if (strings.inputs.isEmpty) {
    throw const InvalidSettingsException(
        'The value of "flutter_gen/colors:" is incorrect.');
  }

  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln();
  buffer.writeln('class ${strings.className} {');
  buffer.writeln('${strings.className}._();');
  buffer.writeln();

  final stringsList = <String>[];
  strings.inputs
      .map((path) => StringPath(join(pubspecFile.parent.path, path)))
      .forEach((stringsFile) {
    if (stringsFile.isJson) {
      final lines = stringsFile.file.readAsLinesSync();
      stringsList.addAll(_generateContent(lines));
    } else {
      throw 'Not supported file type ${stringsFile.mime}.';
    }
  });

  stringsList.distinctBy((item) => item).forEach(buffer.write);

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}

List<String> _generateContent(List<String> lines) {
  final List<String> strings = [];
  final end = lines.length - 1;
  for (int index = 1; index < end; ++index) {
    final items = lines[index].split('"');
    // In valid json line there should be 5 items
    if (items.length != 5) return strings;
    final key = items[1];
    strings.add("static const $key = '$key';");
  }
  return strings;
}
