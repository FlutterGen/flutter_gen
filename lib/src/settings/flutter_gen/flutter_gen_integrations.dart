import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class FlutterGenIntegrations {
  FlutterGenIntegrations(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _flutterSvg = safeCast<bool>(flutterGenMap['flutter_svg']);
    }
  }

  bool _flutterSvg;

  bool get flutterSvg => _flutterSvg ?? false;

  bool get hasFlutterSvg => flutterSvg;
}
