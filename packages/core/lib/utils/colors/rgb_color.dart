/// Reference from: https://pub.dev/packages/color
import 'dart:math';

import 'colors.dart';
import 'css_color_space.dart';
import 'hex_color.dart';
import 'hsl_color.dart';

class RgbColor extends Colors implements CssColorSpace {
  final num r;
  final num g;
  final num b;
  static const int rMin = 0;
  static const int gMin = 0;
  static const int bMin = 0;
  static const int rMax = 255;
  static const int gMax = 255;
  static const int bMax = 255;

  const RgbColor(this.r, this.g, this.b);

  RgbColor toRgbColor() => this;

  HslColor toHslColor() {
    num rf = r / 255;
    num gf = g / 255;
    num bf = b / 255;
    var cMax = [rf, gf, bf].reduce(max);
    var cMin = [rf, gf, bf].reduce(min);
    var delta = cMax - cMin;
    num hue;
    num saturation;
    num luminance;

    if (cMax == rf) {
      hue = 60 * ((gf - bf) / delta % 6);
    } else if (cMax == gf) {
      hue = 60 * ((bf - rf) / delta + 2);
    } else {
      hue = 60 * ((rf - gf) / delta + 4);
    }

    if (hue.isNaN || hue.isInfinite) {
      hue = 0;
    }

    luminance = (cMax + cMin) / 2;

    if (delta == 0) {
      saturation = 0;
    } else {
      saturation = delta / (1 - (luminance * 2 - 1).abs());
    }

    return HslColor(hue, saturation * 100, luminance * 100);
  }

  HexColor toHexColor() => HexColor.fromRgb(r, g, b);

  String toString() => "r: $r, g: $g, b: $b";

  String toCssString() => 'rgb(${r.toInt()}, ${g.toInt()}, ${b.toInt()})';

  Map<String, num> toMap() => {'r': r, 'g': g, 'b': b};
}
