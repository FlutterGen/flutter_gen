import 'package:build/build.dart';
import 'package:flutter_gen/src/settings/flutter/flutter.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config(this._buildStep);

  static const OUTPUT_BASE_DIR = 'lib/';

  final BuildStep _buildStep;
  Flutter flutter;
  FlutterGen flutterGen;

  Future<Config> load() async {
    final assetId = AssetId(_buildStep.inputId.package, 'pubspec.yaml');
    final pubspec = await _buildStep.readAsString(assetId);
    
    assert(pubspec != null, throw 'pubspec.yaml is empty');
    assert(pubspec.isNotEmpty, throw 'Not found pubspec.yaml');

    final properties = loadYaml(pubspec) as YamlMap;
    flutter = Flutter(properties['flutter'] as YamlMap);
    flutterGen = FlutterGen(properties['flutter_gen'] as YamlMap);

    return this;
  }

  bool get hasFlutterGen => flutterGen != null;

  bool get hasFlutter => flutter != null;
}
