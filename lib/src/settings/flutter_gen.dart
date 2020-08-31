import 'package:flutter_gen/src/settings/flutter_gen_assets.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      assets = FlutterGenAssets(flutterGenMap['assets'] as YamlMap);
    }
  }

  FlutterGenAssets assets;
}
