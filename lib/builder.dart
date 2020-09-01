library flutter_gen;

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';

Builder build(BuilderOptions options) {
  return FlutterGenerator();
}

class FlutterGenerator extends Builder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      r'$lib$': [
        'gen/asset.gen.dart',
        'gen/font.gen.dart',
        'gen/colors.gen.dart'
      ]
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final config = await Config(buildStep).load();

    int lineLength;

    if (config.hasFlutterGen) {
      lineLength = config.flutterGen.lineLength;
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutterGen.hasColors) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/colors.gen.dart');
        final generate =
            ColorsGenerator.generate(formatter, config.flutterGen.colors);
        await buildStep.writeAsString(assetsId, generate);
      }
    }

    if (config.hasFlutter) {
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutter.hasAssets) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/asset.gen.dart');
        final generate =
            AssetsGenerator.generate(formatter, config.flutter.assets);
        await buildStep.writeAsString(assetsId, generate);
      }

      if (config.flutter.hasFonts) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/font.gen.dart');
        final generate =
            FontsGenerator.generate(formatter, config.flutter.fonts);

        await buildStep.writeAsString(assetsId, generate);
      }
    }
  }
}
