import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import 'generators/assets_generator.dart';
import 'generators/colors_generator.dart';
import 'generators/fonts_generator.dart';
import 'settings/config.dart';
import 'utils/error.dart';
import 'utils/file.dart';

class FlutterGenerator {
  const FlutterGenerator(
    this.pubspecFile, {
    this.assetsName = 'assets.gen.dart',
    this.colorsName = 'colors.gen.dart',
    this.fontsName = 'fonts.gen.dart',
  });

  final File pubspecFile;
  final String assetsName;
  final String colorsName;
  final String fontsName;

  Future<void> build() async {
    Config config;
    try {
      config = await loadPubspecConfig(pubspecFile);
    } on InvalidSettingsException catch (e) {
      stderr.writeln(e.message);
      return;
    } on FileSystemException catch (e) {
      stderr.writeln(e.message);
      return;
    }

    final flutter = config.pubspec.flutter;
    final flutterGen = config.pubspec.flutterGen;
    final output = config.pubspec.flutterGen.output;
    final lineLength = config.pubspec.flutterGen.lineLength;
    final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

    final absoluteOutput =
        Directory(normalize(join(pubspecFile.parent.path, output)));
    if (!absoluteOutput.existsSync()) {
      absoluteOutput.createSync(recursive: true);
    }

    if (flutterGen.colors.enabled && flutterGen.colors.inputs.isNotEmpty) {
      final generated =
          generateColors(pubspecFile, formatter, flutterGen.colors);
      final colors =
          File(normalize(join(pubspecFile.parent.path, output, colorsName)));
      writeAsString(generated, file: colors);
      print('Generated: ${colors.absolute.path}');
    }

    if (flutterGen.assets.enabled && flutter.assets.isNotEmpty) {
      final generated = generateAssets(
        AssetsGenConfig.fromConfig(pubspecFile, config),
        formatter,
      );
      final assets =
          File(normalize(join(pubspecFile.parent.path, output, assetsName)));
      writeAsString(generated, file: assets);
      print('Generated: ${assets.absolute.path}');
    }

    if (flutterGen.fonts.enabled && flutter.fonts.isNotEmpty) {
      final generated = generateFonts(formatter, flutter.fonts);
      final fonts =
          File(normalize(join(pubspecFile.parent.path, output, fontsName)));
      writeAsString(generated, file: fonts);
      print('Generated: ${fonts.absolute.path}');
    }

    print('FlutterGen finished.');
  }
}
