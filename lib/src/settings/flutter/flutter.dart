import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_fonts.dart';
import 'package:flutter_gen/src/utils/cast.dart';
import 'package:yaml/yaml.dart';

class Flutter {
  Flutter(YamlMap flutterMap) {
    if (flutterMap != null) {
      assets = FlutterAssets(safeCast<YamlList>(flutterMap['assets']));
      fonts = FlutterFonts(safeCast<YamlList>(flutterMap['fonts']));
    }
  }

  FlutterAssets assets;

  FlutterFonts fonts;

  bool get hasAssets => assets != null && assets.hasAssets;

  bool get hasFonts => fonts != null && fonts.hasFonts;
}
