import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';

import '../settings/pubspec.dart';
import '../utils/string.dart';
import 'generator_helper.dart';

String generateFonts(
  DartFormatter formatter,
  List<FlutterFonts> fonts,
) {
  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln('class FontFamily {');
  buffer.writeln('  FontFamily._();');
  buffer.writeln();

  fonts.map((element) => element.family).distinct().sorted().forEach((family) {
    buffer
        .writeln("  static const String ${family.camelCase()} = \'$family\';");
  });

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}
