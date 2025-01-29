import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final dartFormatterLanguageVersion = DartFormatter.latestLanguageVersion;

Future<void> clearTestResults() async {}

Future<List<String>> runAssetsGen(
  String pubspec,
  String generated,
  String fact, {
  String? build,
}) async {
  stdout.writeln('[DEBUG] test: Generate from config...');
  final pubspecFile = File(pubspec);

  File? buildFile;
  if (build != null) {
    buildFile = File(build);
  }

  await FlutterGenerator(
    pubspecFile,
    buildFile: buildFile,
    assetsName: p.basename(generated),
  ).build();

  stdout.writeln('[DEBUG] test: Generate from API...');
  final config = loadPubspecConfig(pubspecFile, buildFile: buildFile);
  final formatter = DartFormatter(
    languageVersion: dartFormatterLanguageVersion,
    pageWidth: config.pubspec.flutterGen.lineLength,
    lineEnding: '\n',
  );

  final actual = await generateAssets(
    AssetsGenConfig.fromConfig(pubspecFile, config),
    formatter,
  );
  final expected = formatter.format(
    File(fact).readAsStringSync().replaceAll('\r\n', '\n'),
  );
  return [actual, expected];
}

/// Assets
Future<void> expectedAssetsGen(
  String pubspec,
  String generated,
  String fact, {
  String? build,
}) async {
  final results = await runAssetsGen(pubspec, generated, fact, build: build);
  final actual = results.first, expected = results.last;
  expect(
    File(generated).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}

Future<List<String>> runColorsGen(
  String pubspec,
  String generated,
  String fact,
) async {
  await FlutterGenerator(
    File(pubspec),
    colorsName: p.basename(generated),
  ).build();

  final pubspecFile = File(pubspec);
  final config = loadPubspecConfig(pubspecFile);
  final formatter = DartFormatter(
    languageVersion: dartFormatterLanguageVersion,
    pageWidth: config.pubspec.flutterGen.lineLength,
    lineEnding: '\n',
  );

  final actual = generateColors(
    pubspecFile,
    formatter,
    config.pubspec.flutterGen.colors,
  );
  final expected = formatter.format(
    File(fact).readAsStringSync().replaceAll('\r\n', '\n'),
  );
  return [actual, expected];
}

/// Colors
Future<void> expectedColorsGen(
  String pubspec,
  String generated,
  String fact,
) async {
  final results = await runColorsGen(pubspec, generated, fact);
  final actual = results.first, expected = results.last;
  expect(
    File(generated).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}

Future<List<String>> runFontsGen(
  String pubspec,
  String generated,
  String fact,
) async {
  await FlutterGenerator(
    File(pubspec),
    fontsName: p.basename(generated),
  ).build();

  final pubspecFile = File(pubspec);
  final config = loadPubspecConfig(pubspecFile);
  final formatter = DartFormatter(
    languageVersion: dartFormatterLanguageVersion,
    pageWidth: config.pubspec.flutterGen.lineLength,
    lineEnding: '\n',
  );

  final actual = generateFonts(
    FontsGenConfig.fromConfig(config),
    formatter,
  );
  final expected = formatter.format(
    File(fact).readAsStringSync().replaceAll('\r\n', '\n'),
  );

  return [actual, expected];
}

/// Fonts
Future<void> expectedFontsGen(
  String pubspec,
  String generated,
  String fact,
) async {
  final results = await runFontsGen(pubspec, generated, fact);
  final actual = results.first, expected = results.last;
  expect(
    File(generated).readAsStringSync(),
    isNotEmpty,
  );
  expect(actual, expected);
}

/// Verify generated package name.
void expectedPackageNameGen(
  String pubspec,
  String? fact,
) {
  final pubspecFile = File(pubspec);
  final config = AssetsGenConfig.fromConfig(
    pubspecFile,
    loadPubspecConfig(pubspecFile),
  );
  final actual = generatePackageNameForConfig(config);
  expect(actual, equals(fact));
}
