import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:yaml/yaml.dart';

import '../settings/flutter.dart';
import '../utils/cast.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';

String generateFonts(DartFormatter formatter, FlutterFonts fonts) {
  if (fonts == null || !fonts.hasFonts) {
    throw InvalidSettingsException(
        'The value of "flutter/fonts:" is incorrect.');
  }

  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln('class FontFamily {');
  buffer.writeln('  FontFamily._();');
  buffer.writeln();

  fonts.fonts
      .cast<YamlMap>()
      .map((element) => safeCast<String>(element['family']))
      .distinct()
      .sorted()
      .forEach((family) {
    buffer
        .writeln("  static const String ${family.camelCase()} = \'$family\';");
  });

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}
