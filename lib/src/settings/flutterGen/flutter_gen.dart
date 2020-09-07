import 'dart:io';

import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_integrations.dart';
import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _output = safeCast<String>(flutterGenMap['output']);
      _integrations = FlutterGenIntegrations(
          safeCast<YamlMap>(flutterGenMap['integrations']));
      _lineLength = safeCast<int>(flutterGenMap['lineLength']);
      _colors = FlutterGenColors(safeCast<YamlMap>(flutterGenMap['colors']));
    }
  }

  String _output;

  String get output =>
      _output != null && FileSystemEntity.isDirectorySync(_output)
          ? _output
          : Config.DEFAULT_OUTPUT;

  int _lineLength;

  int get lineLength => _lineLength ?? Config.DEFAULT_LINE_LENGTH;

  FlutterGenIntegrations _integrations;

  FlutterGenIntegrations get integrations => _integrations;

  bool get hasIntegrations => integrations != null;

  FlutterGenColors _colors;

  FlutterGenColors get colors => _colors;

  bool get hasColors => colors != null;
}
