library flutter_gen;

import 'package:build/build.dart';
import 'package:flutter_gen/assets_generator.dart';
import 'package:flutter_gen/fonts_generator.dart';
import 'package:yaml/yaml.dart';

Builder build(BuilderOptions options) {
  return FlutterGenerator();
}

class FlutterGenerator extends Builder {
  @override
  get buildExtensions => {
        r'$lib$': ['asset.gen.dart', 'color.gen.dart', 'font.gen.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final assetId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    final config = loadYaml(await buildStep.readAsString(assetId)) as YamlMap;

    // flutter/asset key
    final flutter = config["flutter"] as YamlMap;
    if (flutter != null) {
      // Asset
      if (flutter.containsKey("assets")) {
        final output = AssetId(buildStep.inputId.package, 'lib/asset.gen.dart');
        final generate = AssetsGenerator.generate(flutter["assets"]);
        await buildStep.writeAsString(output, generate);
      }
      // Font
      if (flutter.containsKey("fonts")) {
        final output = AssetId(buildStep.inputId.package, 'lib/font.gen.dart');
        final generate = FontsGenerator.generate(flutter["fonts"]);
        await buildStep.writeAsString(output, generate);
      }
    }

    //  flutter_gen key
    final flutterGen = config["flutter_gen"] as YamlMap;
    if (flutterGen != null) {
      if (flutterGen.containsKey("color")) {
        // TODO(wasabeef):color
      }
    }
  }
}
