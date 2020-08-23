library flutter_gen;

import 'dart:async';

import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

Builder build(BuilderOptions options) {
  return FlutterGenerator();
}

class FlutterGenerator extends Builder {
  @override
  get buildExtensions => {
        r'$lib$': ['.gen.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final output = AssetId(buildStep.inputId.package, 'lib/assets.dart');

    final configId = AssetId(buildStep.inputId.package, 'pubspec.yaml');

    final configRaw =
        loadYaml(await buildStep.readAsString(configId)) as YamlMap;
  }
}
