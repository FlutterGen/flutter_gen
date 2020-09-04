import 'dart:io';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/file.dart';
import 'package:path/path.dart';

Builder build(BuilderOptions options) {
  Future(() async {
    await FlutterGenerator(File('pubspec.yaml')).build();
  });
  return EmptyBuilder();
}

class EmptyBuilder extends Builder {
  @override
  Future<void> build(BuildStep buildStep) async {}

  @override
  Map<String, List<String>> get buildExtensions => {};
}

class FlutterGenerator {
  const FlutterGenerator(this.pubspecFile);

  final File pubspecFile;

  Future<void> build() async {
    final config = await Config(pubspecFile).load();

    String output;
    int lineLength;

    if (config.hasFlutterGen) {
      output = config.flutterGen.output;
      lineLength = config.flutterGen.lineLength;
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutterGen.hasColors) {
        final generated =
            generateColors(pubspecFile, formatter, config.flutterGen.colors);
        final colors =
            File(join(pubspecFile.parent.path, output, 'colors.gen.dart'));
        writeAsString(generated, file: colors);
        print('Generated: ${colors.absolute.path}');
      }
    }

    if (config.hasFlutter) {
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutter.hasAssets) {
        final generated =
            generateAssets(pubspecFile, formatter, config.flutter.assets);
        final assets =
            File(join(pubspecFile.parent.path, output, 'assets.gen.dart'));
        writeAsString(generated, file: assets);
        print('Generated: ${assets.absolute.path}');
      }

      if (config.flutter.hasFonts) {
        final generated = generateFonts(formatter, config.flutter.fonts);
        final fonts =
            File(join(pubspecFile.parent.path, output, 'fonts.gen.dart'));
        writeAsString(generated, file: fonts);
        print('Generated: ${fonts.absolute.path}');
      }
    }

    print('FlutterGen finished.');
  }
}
