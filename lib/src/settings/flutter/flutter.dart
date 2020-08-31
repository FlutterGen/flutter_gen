import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_fonts.dart';
import 'package:yaml/yaml.dart';

class Flutter {
  Flutter(YamlMap flutterMap) {
    if (flutterMap != null) {
      _assets = FlutterAssets(flutterMap['assets'] as YamlList);
      _fonts = FlutterFonts(flutterMap['fonts'] as YamlList);
    }
  }

  FlutterAssets _assets;

  FlutterAssets get assets => _assets;

  FlutterFonts _fonts;

  FlutterFonts get fonts => _fonts;

  bool get hasAssets => _assets != null && _assets.hasAssets;

  bool get hasFonts => _fonts != null && _fonts.hasFonts;
}
