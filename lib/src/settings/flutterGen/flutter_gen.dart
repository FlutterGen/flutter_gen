import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_assets.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _assets = FlutterGenAssets(flutterGenMap['assets'] as YamlMap);
      _colors = FlutterGenColors(flutterGenMap['colors'] as YamlMap);
    }
  }

  FlutterGenAssets _assets;

  FlutterGenAssets get assets => _assets;

  FlutterGenColors _colors;

  FlutterGenColors get colors => _colors;

  bool get hasAssets => assets != null;

  bool get hasColors => colors != null;
}
