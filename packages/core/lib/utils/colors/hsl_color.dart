/// Reference from: https://pub.dev/packages/color
import 'colors.dart';
import 'css_color_space.dart';
import 'rgb_color.dart';

class HslColor extends Colors implements CssColorSpace {
  final num h;
  final num s;
  final num l;
  static const num hMin = 0;
  static const num sMin = 0;
  static const num lMin = 0;
  static const num hMax = 360;
  static const num sMax = 100;
  static const num lMax = 100;

  const HslColor(this.h, this.s, this.l);

  RgbColor toRgbColor() {
    var rgb = <num>[0, 0, 0];

    num hue = h / 360 % 1;
    num saturation = s / 100;
    num luminance = l / 100;

    if (hue < 1 / 6) {
      rgb[0] = 1;
      rgb[1] = hue * 6;
    } else if (hue < 2 / 6) {
      rgb[0] = 2 - hue * 6;
      rgb[1] = 1;
    } else if (hue < 3 / 6) {
      rgb[1] = 1;
      rgb[2] = hue * 6 - 2;
    } else if (hue < 4 / 6) {
      rgb[1] = 4 - hue * 6;
      rgb[2] = 1;
    } else if (hue < 5 / 6) {
      rgb[0] = hue * 6 - 4;
      rgb[2] = 1;
    } else {
      rgb[0] = 1;
      rgb[2] = 6 - hue * 6;
    }

    rgb = rgb.map((val) => val + (1 - saturation) * (0.5 - val)).toList();

    if (luminance < 0.5) {
      rgb = rgb.map((val) => luminance * 2 * val).toList();
    } else {
      rgb = rgb.map((val) => luminance * 2 * (1 - val) + 2 * val - 1).toList();
    }

    rgb = rgb.map((val) => (val * 255).round()).toList();

    return RgbColor(rgb[0], rgb[1], rgb[2]);
  }

  HslColor toHslColor() => this;

  String toString() => "h: $h, s: $s%, l: $l%";

  String toCssString() => 'hsl($h, $s%, $l%)';

  Map<String, num> toMap() => {'h': h, 's': s, 'l': l};
}
