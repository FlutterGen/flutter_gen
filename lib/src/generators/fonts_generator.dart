import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_fonts.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:yaml/yaml.dart';

class FontsGenerator {
  static String generate(DartFormatter formatter, FlutterFonts fonts) {
    assert(fonts != null && fonts.hasFonts,
        throw 'The value of "flutter/fonts:" is incorrect.');

    final buffer = StringBuffer();
    buffer.writeln(header());
    buffer.writeln('class FontFamily {');
    buffer.writeln('  FontFamily._();');
    buffer.writeln();

    fonts.fonts
        .cast<YamlMap>()
        .map((element) => element['family'] as String)
        .toSet() // to Set<> for remove duplicated item
        .forEach((family) {
      buffer.writeln(
          "  static const String ${family.camelCase()} = \'$family\';");
    });

    buffer.writeln('}');
    return formatter.format(buffer.toString());
  }
}
