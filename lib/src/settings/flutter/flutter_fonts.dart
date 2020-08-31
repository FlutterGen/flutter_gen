import 'package:yaml/yaml.dart';

class FlutterFonts {
  FlutterFonts(YamlList fonts) {
    if (fonts != null) {
      _fonts = fonts.cast<String>();
    }
  }

  List<String> _fonts;

  List<String> get fonts => _fonts;

  bool get hasFonts => _fonts != null && _fonts.isNotEmpty;
}
