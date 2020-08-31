import 'package:yaml/yaml.dart';

class FlutterAssets {
  FlutterAssets(YamlList assets) {
    if (assets != null) {
      _assets = assets.cast<String>();
    }
  }

  List<String> _assets;

  List<String> get assets => _assets;

  bool get hasAssets => _assets != null && _assets.isNotEmpty;
}
