import 'dart:io';

import 'package:yaml/yaml.dart';

import '../utils/cast.dart';
import 'config.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _output = safeCast<String>(flutterGenMap['output']);
      if (flutterGenMap.containsKey('integrations')) {
        integrations = FlutterGenIntegrations(
            safeCast<YamlMap>(flutterGenMap['integrations']));
      }
      _lineLength = safeCast<int>(flutterGenMap['lineLength']);
      if (flutterGenMap.containsKey('colors')) {
        colors = FlutterGenColors(safeCast<YamlMap>(flutterGenMap['colors']));
      }
    }
  }

  String _output;

  String get output =>
      _output != null && FileSystemEntity.isDirectorySync(_output)
          ? _output
          : Config.defaultOutput;

  int _lineLength;

  int get lineLength => _lineLength ?? Config.defaultLineLength;

  FlutterGenIntegrations integrations;

  bool get hasIntegrations => integrations != null;

  FlutterGenColors colors;

  bool get hasColors => colors != null;
}

class FlutterGenColors {
  FlutterGenColors(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      inputs = safeCast<YamlList>(flutterGenMap['inputs']);
    }
  }

  YamlList inputs;

  bool get hasInputs => inputs != null && inputs.isNotEmpty;
}

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
