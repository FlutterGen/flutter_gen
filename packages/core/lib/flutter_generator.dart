import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/file.dart';
import 'package:path/path.dart';

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

  Future<void> build({Config? config, FileWriter? writer}) async {
    config ??= loadPubspecConfigOrNull(pubspecFile);
    if (config == null) return;

    final flutter = config.pubspec.flutter;
    final flutterGen = config.pubspec.flutterGen;
    final output = config.pubspec.flutterGen.output;
    final lineLength = config.pubspec.flutterGen.lineLength;
    final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

    void defaultWriter(String contents, String path) {
      final file = File(path);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(contents);
    }

    writer ??= defaultWriter;

    final absoluteOutput =
        Directory(normalize(join(pubspecFile.parent.path, output)));
    if (!absoluteOutput.existsSync()) {
      absoluteOutput.createSync(recursive: true);
    }

    if (flutterGen.colors.enabled && flutterGen.colors.inputs.isNotEmpty) {
      final generated =
          generateColors(pubspecFile, formatter, flutterGen.colors);
      final colorsPath =
          normalize(join(pubspecFile.parent.path, output, colorsName));
      writer(generated, colorsPath);
      stdout.writeln('Generated: $colorsPath');
    }

    if (flutterGen.assets.enabled && flutter.assets.isNotEmpty) {
      final generated = generateAssets(
        AssetsGenConfig.fromConfig(pubspecFile, config),
        formatter,
      );
      final assetsPath =
          normalize(join(pubspecFile.parent.path, output, assetsName));
      writer(generated, assetsPath);
      stdout.writeln('Generated: $assetsPath');
    }

    if (flutterGen.fonts.enabled && flutter.fonts.isNotEmpty) {
      final generated =
          generateFonts(formatter, flutter.fonts, flutterGen.fonts);
      final fontsPath =
          normalize(join(pubspecFile.parent.path, output, fontsName));
      writer(generated, fontsPath);
      stdout.writeln('Generated: $fontsPath');
    }

    stdout.writeln('FlutterGen finished.');
  }
}
