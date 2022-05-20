// ignore_for_file: prefer_const_constructors

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';

import '../settings/pubspec.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';

String generateFonts(
  DartFormatter formatter,
  List<FlutterFonts> fonts,
) {
  if (fonts.isEmpty) {
    throw InvalidSettingsException(
        'The value of "flutter/fonts:" is incorrect.');
  }

  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln('class FontFamily {');
  buffer.writeln('FontFamily._();');
  buffer.writeln();

  fonts.map((element) => element.family).distinct().sorted().forEach((family) {
    buffer.writeln("""/// Font family: $family
    static const String ${family.camelCase()} = '$family';""");
  });

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}
