import 'package:yaml/yaml.dart';

class FlutterAssets {
  FlutterAssets(YamlList assets) {
    if (assets != null) {
      this.assets = assets.cast<String>();
    }
  }

  List<String> assets;

  bool get hasAssets => assets != null && assets.isNotEmpty;
}
