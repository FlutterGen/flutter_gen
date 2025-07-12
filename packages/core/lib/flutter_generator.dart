import 'dart:io' show Directory, File;

import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/file.dart';
import 'package:flutter_gen_core/utils/formatter.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:path/path.dart' show join, normalize;

class FlutterGenerator {
  const FlutterGenerator(
    this.pubspecFile, {
    this.buildFile,
    this.assetsName = 'assets.gen.dart',
    this.colorsName = 'colors.gen.dart',
    this.fontsName = 'fonts.gen.dart',
    this.overrideOutputPath,
  });

  final File pubspecFile;
  final File? buildFile;
  final String assetsName;
  final String colorsName;
  final String fontsName;
  final String? overrideOutputPath;

  Future<void> build({Config? config, FileWriter? writer}) async {
    config ??= loadPubspecConfigOrNull(pubspecFile, buildFile: buildFile);
    if (config == null) {
      return;
    }

    final formatter = buildDartFormatterFromConfig(config);
    final flutter = config.pubspec.flutter;
    final flutterGen = config.pubspec.flutterGen;
    final output = config.pubspec.flutterGen.output;

    void defaultWriter(String contents, String path) {
      final file = File(path);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(contents);
    }

    writer ??= defaultWriter;

    final absoluteOutput = Directory(
      normalize(overrideOutputPath ?? join(pubspecFile.parent.path, output)),
    );
    if (!absoluteOutput.existsSync()) {
      absoluteOutput.createSync(recursive: true);
    }

    if (flutterGen.assets.enabled && flutter.assets.isNotEmpty) {
      final generated = await generateAssets(
        AssetsGenConfig.fromConfig(pubspecFile, config),
        formatter,
      );
      final assetsPath = normalize(join(absoluteOutput.path, assetsName));
      writer(generated, assetsPath);
      log.info('[FlutterGen] Generated: $assetsPath');
    }

    if (flutterGen.colors.enabled && flutterGen.colors.inputs.isNotEmpty) {
      final generated = generateColors(
        pubspecFile,
        formatter,
        flutterGen.colors,
      );
      final colorsPath = normalize(join(absoluteOutput.path, colorsName));
      writer(generated, colorsPath);
      log.info('[FlutterGen] Generated: $colorsPath');
    }

    if (flutterGen.fonts.enabled && flutter.fonts.isNotEmpty) {
      final generated = generateFonts(
        FontsGenConfig.fromConfig(config),
        formatter,
      );
      final fontsPath = normalize(join(absoluteOutput.path, fontsName));
      writer(generated, fontsPath);
      log.info('[FlutterGen] Generated: $fontsPath');
    }

    log.info('[FlutterGen] Finished generating.');
  }
}
