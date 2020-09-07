import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class FlutterGenColors {
  FlutterGenColors(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _inputs = safeCast<YamlList>(flutterGenMap['inputs']);
    }
  }

  YamlList _inputs;

  YamlList get inputs => _inputs;

  bool get hasInputs => _inputs != null && _inputs.isNotEmpty;
}
