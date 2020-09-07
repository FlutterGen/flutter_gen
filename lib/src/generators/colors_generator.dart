import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/color_path.dart';
import 'package:flutter_gen/src/settings/color_set.dart';
import 'package:flutter_gen/src/settings/flutter_gen/flutter_gen_colors.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
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
  buffer.writeln(header);
  buffer.writeln("import 'package:flutter/painting.dart';");
  buffer.writeln("import 'package:flutter/material.dart';");
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
        return Color.fromXmlElement(element);
      }));
    } else {
      throw 'Not supported file type ${colorFile.mime}.';
    }
  });

  colorList
      .distinctBy((color) => color.hex)
      .map(_colorToStatement)
      .forEach(buffer.writeln);

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}

String _colorToStatement(Color color) {
  final hex = colorFromHex(color.hex);
  if (color.type == 'material') {
    final swatch = swatchFromPrimaryHex(hex);
    return '''
  static const MaterialColor ${color.name.camelCase()} = MaterialColor(
    ${swatch[500]},
    <int, Color>{
      ${swatch.entries.map((e) => '${e.key}: Color(${e.value}),').join('\n')}
    },
  );''';
  } else if (color.type == null) {
    return '  static const Color ${color.name.camelCase()} = Color($hex);';
  }
  throw 'Not supported color type ${color.type}.';
}
