import 'package:yaml/yaml.dart';

class Flutter {
  Flutter(YamlMap flutterMap) {
    if (flutterMap != null) {
      _assets = flutterMap['assets'] as YamlList;
      _fonts = flutterMap['fonts'] as YamlList;
    }
  }

  YamlList _assets;

  YamlList get assets => _assets;

  YamlList _fonts;

  YamlList get fonts => _fonts;

  bool get hasAssets => _assets != null && _assets.isNotEmpty;

  bool get hasFonts => _fonts != null && _fonts.isNotEmpty;
}
