import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/color_path.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:flutter_gen/src/utils/color.dart';
import 'package:xml/xml.dart';

class ColorsGenerator {
  static String generate(FlutterGenColors flutterGenColors) {
    if (flutterGenColors == null) {
      throw InvalidInputException;
    }

    final buffer = StringBuffer();
    buffer.writeln(header());
    buffer.writeln("import 'package:flutter/painting.dart';");
    buffer.writeln();
    buffer.writeln('class ColorName {');
    buffer.writeln('  ColorName._();');
    buffer.writeln();

    flutterGenColors.inputs
        .cast<String>()
        .map((file) => ColorPath(file))
        .forEach((colorFile) {
      final data = colorFile.file.readAsStringSync();
      if (colorFile.isXml) {
        final document = XmlDocument.parse(data);
        final colors = document.findAllElements('color');
        for (final color in colors) {
          buffer.writeln(
              "  static Color ${camelCase(color.getAttribute('name'))} = const Color(${colorFromHex(color.text)});");
        }
      } else if (colorFile.isJson) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        map.cast<String, String>().forEach((key, value) {
          buffer.writeln(
              '  static Color ${camelCase(key)} = const Color(${colorFromHex(value)});');
        });
      }
    });

    buffer.writeln('}');
    return DartFormatter().format(buffer.toString());
  }
}
