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
    final config = Config(pubspecFile);
    try {
      await config.load();
    } on InvalidSettingsException catch (e) {
      stderr.writeln(e.message);
      return;
    } on FileSystemException catch (e) {
      stderr.writeln(e.message);
      return;
    }

    var output = Config.defaultOutput;
    var lineLength = Config.defaultLineLength;

    if (config.hasFlutterGen) {
      output = config.flutterGen.output;
      lineLength = config.flutterGen.lineLength;
      final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

      if (config.flutterGen.hasColors) {
        final generated =
            generateColors(pubspecFile, formatter, config.flutterGen.colors);
        final colors =
            File(normalize(join(pubspecFile.parent.path, output, colorsName)));
        writeAsString(generated, file: colors);
        print('Generated: ${colors.absolute.path}');
      }
    }

    if (config.hasFlutter) {
      final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

      if (config.flutter.hasAssets) {
        final generated = generateAssets(
            pubspecFile, formatter, config.flutterGen, config.flutter.assets);
        final assets =
            File(normalize(join(pubspecFile.parent.path, output, assetsName)));
        writeAsString(generated, file: assets);
        print('Generated: ${assets.absolute.path}');
      }

      if (config.flutter.hasFonts) {
        final generated = generateFonts(formatter, config.flutter.fonts);
        final fonts =
            File(normalize(join(pubspecFile.parent.path, output, fontsName)));
        writeAsString(generated, file: fonts);
        print('Generated: ${fonts.absolute.path}');
      }
    }

    print('FlutterGen finished.');
  }
}
