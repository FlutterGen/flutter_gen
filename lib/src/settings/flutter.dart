import 'package:yaml/yaml.dart';

import '../utils/cast.dart';

class Flutter {
  Flutter(YamlMap flutterMap) {
    if (flutterMap != null) {
      if (flutterMap.containsKey('assets')) {
        assets = FlutterAssets(safeCast<YamlList>(flutterMap['assets']));
      }
      if (flutterMap.containsKey('fonts')) {
        fonts = FlutterFonts(safeCast<YamlList>(flutterMap['fonts']));
      }
    }
  }

  FlutterAssets assets;

  FlutterFonts fonts;

  bool get hasAssets => assets != null && assets.hasAssets;

  bool get hasFonts => fonts != null && fonts.hasFonts;
}

class FlutterAssets {
  FlutterAssets(YamlList assets) {
    if (assets != null) {
      this.assets = assets.cast<String>();
    }
  }

  List<String> assets;

  bool get hasAssets => assets != null && assets.isNotEmpty;
}

class FlutterFonts {
  FlutterFonts(YamlList fonts) {
    if (fonts != null) {
      this.fonts = fonts.cast<String>();
    }
  }

  List<String> fonts;

  bool get hasFonts => fonts != null && fonts.isNotEmpty;
}
