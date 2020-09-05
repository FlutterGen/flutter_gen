import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/color_path.dart';
import 'package:flutter_gen/src/settings/color_set.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:flutter_gen/src/utils/cast.dart';
import 'package:flutter_gen/src/utils/color.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

String generateColors(
    File pubspecFile, DartFormatter formatter, FlutterGenColors colors) {
  assert(
      colors != null, throw 'The value of "flutter_gen/colors:" is incorrect.');
  assert(colors.hasInputs,
      throw 'The value of "flutter_gen/colors/inputs:" is incorrect.');

  final buffer = StringBuffer();
  buffer.writeln(header());
  buffer.writeln("import 'package:flutter/painting.dart';");
  buffer.writeln();
  buffer.writeln('class ColorName {');
  buffer.writeln('  ColorName._();');
  buffer.writeln();

  final colorList = <Color>[];
  colors.inputs
      .cast<String>()
      .map((file) => ColorPath(join(pubspecFile.parent.path, file)))
      .forEach((colorFile) {
    final data = colorFile.file.readAsStringSync();
    if (colorFile.isXml) {
      colorList.addAll(
          XmlDocument.parse(data).findAllElements('color').map((element) {
        return Color(element.getAttribute('name'), element.text);
      }));
    } else if (colorFile.isJson) {
      safeCast<Map<String, dynamic>>(jsonDecode(data))
          .cast<String, String>()
          .forEach((key, value) => colorList.add(Color(key, value)));
    } else {
      throw 'Not supported file type.';
    }
  });

  // to Set<> for remove duplicated item
  for (final color in {...colorList}) {
    buffer.writeln(
        '  static const Color ${color.name.camelCase()} = Color(${colorFromHex(color.hex)});');
  }

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}
