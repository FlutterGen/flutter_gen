import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_assets.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      assets = FlutterGenAssets(flutterGenMap['assets'] as YamlMap);
      colors = FlutterGenColors(flutterGenMap['colors'] as YamlMap);
    }
  }

  FlutterGenAssets assets;
  FlutterGenColors colors;
}
