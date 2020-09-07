import 'package:yaml/yaml.dart';

class FlutterFonts {
  FlutterFonts(YamlList fonts) {
    if (fonts != null) {
      this.fonts = fonts.cast<String>();
    }
  }

  List<String> fonts;

  bool get hasFonts => fonts != null && fonts.isNotEmpty;
}
