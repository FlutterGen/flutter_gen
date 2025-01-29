// ignore_for_file: prefer_const_constructors

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';

class FontsGenConfig {
  FontsGenConfig._(
    this._packageName,
    this.flutterGen,
    this.fonts,
  );

  factory FontsGenConfig.fromConfig(Config config) {
    return FontsGenConfig._(
      config.pubspec.packageName,
      config.pubspec.flutterGen,
      config.pubspec.flutter.fonts,
    );
  }

  final String _packageName;
  final FlutterGen flutterGen;
  final List<FlutterFonts> fonts;

  String get packageParameterLiteral =>
      flutterGen.fonts.outputs.packageParameterEnabled ? _packageName : '';
}

String generateFonts(
  FontsGenConfig config,
  DartFormatter formatter,
) {
  final fonts = config.fonts;
  final fontsConfig = config.flutterGen.fonts;
  if (fonts.isEmpty) {
    throw InvalidSettingsException(
      'The value of "flutter/fonts:" is incorrect.',
    );
  }

  final buffer = StringBuffer();
  final className = fontsConfig.outputs.className;
  buffer.writeln(header);
  buffer.writeln(ignore);
  buffer.writeln('class $className {');
  buffer.writeln('$className._();');
  buffer.writeln();

  final isPackage = config.packageParameterLiteral.isNotEmpty;
  if (isPackage) {
    buffer.writeln("static const String package = '${config._packageName}';");
    buffer.writeln();
  }

  fonts.map((element) => element.family).distinct().sorted().forEach((family) {
    final keyName = isPackage ? 'packages/\$package/$family' : family;
    buffer.writeln("""/// Font family: $family
    static const String ${family.camelCase()} = '$keyName';""");
  });

  buffer.writeln('}');
  return formatter.format(buffer.toString());
}
