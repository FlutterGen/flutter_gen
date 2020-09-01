import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _colors = FlutterGenColors(flutterGenMap['colors'] as YamlMap);
    }
  }

  FlutterGenColors _colors;

  FlutterGenColors get colors => _colors;

  bool get hasColors => colors != null;
}
