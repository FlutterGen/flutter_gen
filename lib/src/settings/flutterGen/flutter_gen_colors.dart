import 'package:yaml/yaml.dart';

class FlutterGenColors {
  FlutterGenColors(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _inputs = flutterGenMap['inputs'] as YamlList;
    }
  }

  YamlList _inputs;

  YamlList get inputs => _inputs;

  bool get hasInputs => _inputs != null && _inputs.isNotEmpty;
}
