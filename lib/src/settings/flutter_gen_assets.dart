import 'package:yaml/yaml.dart';

class FlutterGenAssets {
  FlutterGenAssets(YamlMap flutterMap) {
    if (flutterMap != null) {
      _fullPathName = flutterMap['fullPathName'] as bool;
    }
  }

  bool _fullPathName;

  bool get fullPathName => _fullPathName ?? false;
}
