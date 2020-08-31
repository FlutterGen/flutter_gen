library flutter_gen;

import 'package:build/build.dart';
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

    if (config.hasFlutterGen) {
      if (config.flutterGen.hasColors) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/colors.gen.dart');
        final generate = ColorsGenerator.generate(config.flutterGen.colors);
        await buildStep.writeAsString(assetsId, generate);
      }
    }

    if (config.hasFlutter) {
      if (config.flutter.hasAssets) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/asset.gen.dart');

        final generate = AssetsGenerator.generate(config.flutter.assets);
        await buildStep.writeAsString(assetsId, generate);
      }

      if (config.flutter.hasFonts) {
        final assetsId =
            AssetId(buildStep.inputId.package, 'lib/gen/font.gen.dart');
        final generate = FontsGenerator.generate(config.flutter.fonts);
        await buildStep.writeAsString(assetsId, generate);
      }
    }
  }
}
