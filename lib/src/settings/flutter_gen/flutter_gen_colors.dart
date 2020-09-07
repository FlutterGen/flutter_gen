import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class FlutterGenColors {
  FlutterGenColors(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      inputs = safeCast<YamlList>(flutterGenMap['inputs']);
    }
  }

  YamlList inputs;

  bool get hasInputs => inputs != null && inputs.isNotEmpty;
}
