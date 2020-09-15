import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

import '../settings/color_path.dart';
import '../settings/flutter_gen.dart';
import '../utils/color.dart';
import '../utils/error.dart';
import '../utils/string.dart';
import 'generator_helper.dart';

String generateColors(
    File pubspecFile, DartFormatter formatter, FlutterGenColors colors) {
  if (colors == null || !colors.hasInputs) {
    throw InvalidSettingsException(
        'The value of "flutter_gen/colors:" is incorrect.');
  }

  final buffer = StringBuffer();
  buffer.writeln(header);
  buffer.writeln("import 'package:flutter/painting.dart';");
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln('class ColorName {');
  buffer.writeln('  ColorName._();');
  buffer.writeln();

  final colorList = <_Color>[];
  colors.inputs
      .cast<String>()
      .map((file) => ColorPath(join(pubspecFile.parent.path, file)))
      .forEach((colorFile) {
    final data = colorFile.file.readAsStringSync();
    if (colorFile.isXml) {
      colorList.addAll(
          XmlDocument.parse(data).findAllElements('color').map((element) {
        return _Color.fromXmlElement(element);
      }));
    } else {
      throw 'Not supported file type ${colorFile.mime}.';
    }
  });

  colorList
      .distinctBy((color) => color.name)
      .sortedBy((color) => color.name)
      .map(_colorStatement)
      .forEach(buffer.writeln);

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}

String _colorStatement(_Color color) {
  if (color.type == 'material') {
    final swatch = swatchFromPrimaryHex(color.hex);
    return '''
  static const MaterialColor ${color.name.camelCase()} = MaterialColor(
    ${swatch[500]},
    <int, Color>{
      ${swatch.entries.map((e) => '${e.key}: Color(${e.value}),').join('\n')}
    },
  );''';
  } else if (color.type == null) {
    // ignore: lines_longer_than_80_chars
    return '  static const Color ${color.name.camelCase()} = Color(${colorFromHex(color.hex)});';
  }
  throw 'Not supported color type ${color.type}.';
}

class _Color {
  const _Color(
    this.name,
    this.type,
    this.hex,
  );

  _Color.fromXmlElement(XmlElement element)
      : this(
          element.getAttribute('name'),
          element.getAttribute('type'),
          element.text,
        );

  final String name;

  final String hex;

  final String type;
}
