import 'package:yaml/yaml.dart';

class FlutterGenAssets {
  FlutterGenAssets(YamlMap flutterGenMap) {
    if (flutterGenMap != null) {
      _fullPathName = flutterGenMap['fullPathName'] as bool;
    }
  }

  bool _fullPathName;

  bool get fullPathName => _fullPathName ?? false;
}
