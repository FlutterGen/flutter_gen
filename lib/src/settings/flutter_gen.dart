import 'dart:io';

import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _output = safeCast<String>(flutterGenMap['output']);
      if (flutterGenMap.containsKey('integrations')) {
        integrations = FlutterGenIntegrations(
            safeCast<YamlMap>(flutterGenMap['integrations']));
      }
      if (flutterGenMap.containsKey('assets')) {
        assets = FlutterGenAssets(safeCast<YamlMap>(flutterGenMap['assets']));
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
          : Config.DEFAULT_OUTPUT;

  int _lineLength;

  int get lineLength => _lineLength ?? Config.DEFAULT_LINE_LENGTH;

  FlutterGenIntegrations integrations;

  bool get hasIntegrations => integrations != null;

  FlutterGenAssets assets;

  bool get hasAssets => assets != null;

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

class FlutterGenAssets {
  FlutterGenAssets(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      style = safeCast<String>(flutterGenMap['style']);
    }
  }

  String style;
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
