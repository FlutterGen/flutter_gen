/// Reference from: https://pub.dev/packages/color
import 'hex_color.dart';
import 'hsl_color.dart';
import 'rgb_color.dart';

abstract class Colors {
  const Colors();

  const factory Colors.rgb(num r, num g, num b) = RgbColor;

  factory Colors.hex(String hexCode) = HexColor;

  const factory Colors.hsl(num h, num s, num l) = HslColor;

  RgbColor toRgbColor();

  HexColor toHexColor() => toRgbColor().toHexColor();

  HslColor toHslColor();

  String toString();

  Map<String, num> toMap();
}
