import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen_colors.dart';
import 'package:yaml/yaml.dart';

class FlutterGen {
  FlutterGen(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _output = flutterGenMap['output'] as String;
      _lineLength = flutterGenMap['lineLength'] as int;
      _colors = FlutterGenColors(flutterGenMap['colors'] as YamlMap);
    }
  }

  String _output;

  String get output => _output ?? Config.DEFAULT_OUTPUT;

  int _lineLength;

  int get lineLength => _lineLength;

  FlutterGenColors _colors;

  FlutterGenColors get colors => _colors;

  bool get hasColors => colors != null;
}
