/// Reference from: https://pub.dev/packages/color
import 'css_color_space.dart';
import 'rgb_color.dart';

class HexColor extends RgbColor implements CssColorSpace {
  factory HexColor(String hexCode) {
    if (hexCode.startsWith('#')) {
      hexCode = hexCode.substring(1);
    }
    var hexDigits = hexCode.split('');
    var r = int.parse(hexDigits.sublist(0, 2).join(), radix: 16);
    var g = int.parse(hexDigits.sublist(2, 4).join(), radix: 16);
    var b = int.parse(hexDigits.sublist(4).join(), radix: 16);
    return HexColor.fromRgb(r, g, b);
  }

  const HexColor.fromRgb(num r, num g, num b) : super(r, g, b);

  get rHex => r.toInt().toRadixString(16).padLeft(2, '0');

  get gHex => g.toInt().toRadixString(16).padLeft(2, '0');

  get bHex => b.toInt().toRadixString(16).padLeft(2, '0');

  HexColor toHexColor() => this;

  String toString() => '$rHex$gHex$bHex';

  String toCssString() => '#$rHex$gHex$bHex';
}
