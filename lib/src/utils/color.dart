String colorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceFirst('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  return '0x$hexColor';
}

/// [Material Design Color Generator](https://github.com/mbitson/mcg)
/// Constantin logic: https://github.com/mbitson/mcg/blob/858cffea0d79ac143d590d110fbe20a1ea54d59d/scripts/controllers/ColorGeneratorCtrl.js#L238
Map<int, String> swatchFromPrimaryHex(String primaryHex) {
  final primary = _Rgb.fromHex(int.parse(primaryHex));
  const baseLight = _Rgb.fromHex(0xffffff);
  final baseDark = primary * primary;
  return {
    50: _Rgb.mix(baseLight, primary, 12).toHexString(),
    100: _Rgb.mix(baseLight, primary, 30).toHexString(),
    200: _Rgb.mix(baseLight, primary, 50).toHexString(),
    300: _Rgb.mix(baseLight, primary, 70).toHexString(),
    400: _Rgb.mix(baseLight, primary, 85).toHexString(),
    500: _Rgb.mix(baseLight, primary, 100).toHexString(),
    600: _Rgb.mix(baseDark, primary, 87).toHexString(),
    700: _Rgb.mix(baseDark, primary, 70).toHexString(),
    800: _Rgb.mix(baseDark, primary, 54).toHexString(),
    900: _Rgb.mix(baseDark, primary, 25).toHexString(),
  };
}

class _Rgb {
  const _Rgb(int r, int g, int b)
      : value = ((0xff << 24) |
                ((r & 0xff) << 16) |
                ((g & 0xff) << 8) |
                ((b & 0xff) << 0)) &
            0xFFFFFFFF;

  const _Rgb.fromHex(int value) : value = (value | 0xFF000000) & 0xFFFFFFFF;

  final int value;

  int get r => (0x00ff0000 & value) >> 16;

  int get g => (0x0000ff00 & value) >> 8;

  int get b => (0x000000ff & value) >> 0;

  // https://github.com/mbitson/mcg/blob/858cffea0d79ac143d590d110fbe20a1ea54d59d/scripts/controllers/ColorGeneratorCtrl.js#L221
  _Rgb operator *(_Rgb other) {
    return _Rgb(
      (r * other.r / 255).floor(),
      (g * other.g / 255).floor(),
      (b * other.b / 255).floor(),
    );
  }

  String toHexString() {
    return '0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  // https://github.com/bgrins/TinyColor/blob/96592a5cacdbf4d4d16cd7d39d4d6dd28da9bd5f/tinycolor.js#L701
  static _Rgb mix(
    _Rgb color1,
    _Rgb color2,
    int amount,
  ) {
    assert(amount >= 0 && amount <= 100);
    final p = amount / 100;
    return _Rgb(
      ((color2.r - color1.r) * p + color1.r).round(),
      ((color2.g - color1.g) * p + color1.g).round(),
      ((color2.b - color1.b) * p + color1.b).round(),
    );
  }
}
