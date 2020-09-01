import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/color_path.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:flutter_gen/src/utils/color.dart';
import 'package:xml/xml.dart';

class ColorsGenerator {
  static String generate(DartFormatter formatter, FlutterGenColors colors) {
    assert(colors != null,
        throw 'The value of "flutter_gen/colors:" is incorrect.');
    assert(colors.hasInputs,
        throw 'The value of "flutter_gen/colors/inputs:" is incorrect.');

    final buffer = StringBuffer();
    buffer.writeln(header());
    buffer.writeln("import 'package:flutter/painting.dart';");
    buffer.writeln();
    buffer.writeln('class ColorName {');
    buffer.writeln('  ColorName._();');
    buffer.writeln();

    colors.inputs
        .cast<String>()
        .map((file) => ColorPath(file))
        .forEach((colorFile) {
      final data = colorFile.file.readAsStringSync();
      if (colorFile.isXml) {
        final document = XmlDocument.parse(data);
        for (final color in document.findAllElements('color')) {
          buffer.writeln(
              "  static Color ${camelCase(color.getAttribute('name'))} = const Color(${colorFromHex(color.text)});");
        }
      } else if (colorFile.isJson) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        map.cast<String, String>().forEach((key, value) {
          buffer.writeln(
              '  static Color ${camelCase(key)} = const Color(${colorFromHex(value)});');
        });
      } else {
        throw 'Not supported file type.';
      }
    });

    buffer.writeln('}');
    return formatter.format(buffer.toString());
  }
}
