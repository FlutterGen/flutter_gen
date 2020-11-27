import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/flutter_generator.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

Future<void> clearTestResults() async {}

/// Assets
void expectedAssetsGen(String yaml, String gen, String fact) async {
  await FlutterGenerator(File(yaml), assetsName: basename(gen)).build();

  final pubspec = File(yaml);
  final config = await Config(pubspec).load();
  final formatter =
      DartFormatter(pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

  final actual = generateAssets(
      pubspec, formatter, config.flutterGen, config.flutter.assets);
  final expected = File(fact).readAsStringSync().replaceAll('\r\n', '\n');

  expect(
    File(gen).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}

/// Colors
void expectedColorsGen(String yaml, String gen, String fact) async {
  await FlutterGenerator(File(yaml)).build();

  final pubspec = File(yaml);
  final config = await Config(pubspec).load();
  final formatter =
      DartFormatter(pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

  final actual = generateColors(pubspec, formatter, config.flutterGen.colors);
  final expected = File(fact).readAsStringSync().replaceAll('\r\n', '\n');

  expect(
    File(gen).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}

/// Fonts
void expectedFontsGen(String yaml, String gen, String fact) async {
  await FlutterGenerator(File(yaml)).build();

  final pubspec = File(yaml);
  final config = await Config(pubspec).load();
  final formatter =
      DartFormatter(pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

  final actual = generateFonts(formatter, config.flutter.fonts);
  final expected = File(fact).readAsStringSync().replaceAll('\r\n', '\n');

  expect(
    File(gen).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}
