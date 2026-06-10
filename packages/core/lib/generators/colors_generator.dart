import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/settings/color_path.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/color.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:path/path.dart';
import 'package:xml/xml.dart';

String generateColors(
  File pubspecFile,
  DartFormatter formatter,
  FlutterGenColors colorsConfig,
) {
  if (colorsConfig.inputs.isEmpty) {
    throw const InvalidSettingsException(
      'The value of "flutter_gen/colors:" is incorrect.',
    );
  }

  final buffer = StringBuffer();
  final className = colorsConfig.outputs.className;
  final style = colorsConfig.outputs.style;
  buffer.writeln('// dart format width=${formatter.pageWidth}');
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln("import 'package:flutter/painting.dart';");
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  switch (style) {
    case FlutterGenElementColorsOutputsStyle.wrapperClassStyle:
      buffer.writeln('class $className extends Color {');
      buffer.writeln('const $className(super.value);');
      buffer.writeln();
    case FlutterGenElementColorsOutputsStyle.plainStyle:
      buffer.writeln('abstract final class $className {');
      buffer.writeln();
  }

  final colorList = <_Color>[];
  colorsConfig.inputs
      .map((file) => ColorPath(join(pubspecFile.parent.path, file)))
      .forEach((colorFile) {
    final data = colorFile.file.readAsStringSync();
    if (colorFile.isXml) {
      colorList.addAll(
        XmlDocument.parse(data).findAllElements('color').map((element) {
          return _Color.fromXmlElement(element);
        }),
      );
    } else {
      throw 'Not supported file type ${colorFile.mime}.';
    }
  });

  colorList
      .distinctBy((color) => color.name)
      .sortedBy((color) => color.name)
      .map((color) => _colorStatement(color, className, style))
      .forEach(buffer.write);

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}

String _colorStatement(
  _Color color,
  String className,
  FlutterGenElementColorsOutputsStyle style,
) {
  final isWrapper =
      style == FlutterGenElementColorsOutputsStyle.wrapperClassStyle;
  // In the wrapper-class style only normal colors change: they are constructed
  // with the generated type's constructor and need no type annotation. Material
  // and material-accent colors are emitted exactly as in the plain style.
  final name = color.name.camelCase();

  final buffer = StringBuffer();
  if (color.isMaterial) {
    final swatch = swatchFromPrimaryHex(color.hex);
    final statement = '''/// MaterialColor:
        ${swatch.entries.map((e) => '///   ${e.key}: ${hexFromColor(e.value)}').join('\n')}
        static const MaterialColor $name = MaterialColor(
    ${swatch[500]},
    <int, Color>{
      ${swatch.entries.map((e) => '${e.key}: Color(${e.value}),').join('\n')}
    },
  );''';
    buffer.writeln(statement);
  }
  if (color.isMaterialAccent) {
    final accentSwatch = accentSwatchFromPrimaryHex(color.hex);
    final statement = '''/// MaterialAccentColor:
        ${accentSwatch.entries.map((e) => '///   ${e.key}: ${hexFromColor(e.value)}').join('\n')}
        static const MaterialAccentColor ${name}Accent = MaterialAccentColor(
   ${accentSwatch[200]},
   <int, Color>{
     ${accentSwatch.entries.map((e) => '${e.key}: Color(${e.value}),').join('\n')}
    },
  );''';
    buffer.writeln(statement);
  }
  if (color.isNormal) {
    final comment = '/// Color: ${color.hex}';
    // The wrapper type is inferred from the constructor, so no annotation.
    final declaration = isWrapper ? 'static const' : 'static const Color';
    final colorType = isWrapper ? className : 'Color';
    final statement =
        '''$declaration $name = $colorType(${colorFromHex(color.hex)});''';

    buffer.writeln(comment);
    buffer.writeln(statement);
  }
  return buffer.toString();
}

class _Color {
  const _Color(
    this.name,
    this.hex,
    this._types,
  );

  _Color.fromXmlElement(XmlElement element)
      : this(
          element.getAttribute('name')!,
          element.innerText,
          element.getAttribute('type')?.split(' ') ?? List.empty(),
        );

  final String name;

  final String hex;

  final List<String> _types;

  bool get isNormal => _types.isEmpty;

  bool get isMaterial => _types.contains('material');

  bool get isMaterialAccent => _types.contains('material-accent');
}
