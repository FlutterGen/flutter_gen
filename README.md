<p align="center">
  <a href="https://pub.dev/packages/flutter_gen">
    <img src="https://github.com/FlutterGen/flutter_gen/raw/main/art/logo.png" width="480px"/>
  </a>
</p>
<p align="center">
  <a href="https://pub.dartlang.org/packages/flutter_gen">
    <img src="https://img.shields.io/pub/v/flutter_gen.svg">
  </a>
  <a href="https://github.com/FlutterGen/flutter_gen/actions?query=workflow%3A%22Dart+CI%22">
    <img src="https://github.com/FlutterGen/flutter_gen/workflows/Dart%20CI/badge.svg" />
  </a>
  <a href="https://codecov.io/gh/FlutterGen/flutter_gen">
    <img src="https://codecov.io/gh/FlutterGen/flutter_gen/branch/main/graph/badge.svg" />
  </a>
  <a href="https://pub.dev/packages/effective_dart">
    <img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" />
  </a>
</p>

The Flutter code generator for your assets, fonts, colors, … — Get rid of all String-based APIs.

Inspired by [SwiftGen](https://github.com/SwiftGen/SwiftGen).

## Motivation.

Using asset path string directly is not safe.

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/profile.jpg
```

❌ **Bad**  
What would happen if you made a typo?

```dart
Widget build(BuildContext context) {
  return Image.asset('assets/images/profile.jpeg');
}

// The following assertion was thrown resolving an image codec:
// Unable to load asset: assets/images/profile.jpeg
```

⭕️ **Good**  
We want to use it safely.

```dart
Widget build(BuildContext context) {
  return Assets.images.profile.image();
}
```

## Installation

Run `fluttergen` after the configuration [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec).

### Use this package as an executable

#### Using a Homebrew Formula


1. Install [FlutterGen]

```sh
$ brew install FlutterGen/tap/fluttergen
```

2. Use [FlutterGen]

```sh
$ fluttergen -h

$ fluttergen -c example/pubspec.yaml
```

#### Using a Dart command-line

1. Install [FlutterGen]

```sh
$ pub global activate flutter_gen

$ export PATH="$PATH":"$HOME/.pub-cache/bin"
```

2. Use [FlutterGen]

```sh
$ fluttergen -h

$ fluttergen -c example/pubspec.yaml
```

### Use this package as a part of build_runner

1. Add [build_runner] and [FlutterGen] to your package's pubspec.yaml file:

```
dev_dependencies:
  build_runner:
  flutter_gen:
```

2. Install [FlutterGen]

```sh
$ flutter pub get
```

3. Use [FlutterGen]

```
$ flutter packages pub run build_runner build
```

## Configuration file

[FlutterGen] generates dart files based on the key **`flutter`** and **`flutter_gen`** of [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec).

```yaml
# pubspec.yaml
# ...

flutter_gen:
  output: lib/gen/ # Optional (default: lib/gen/)
  lineLength: 80 # Optional (default: 80)
  
  integrations:
    flutter_svg: true

  colors:
    inputs:
      - assets/color/colors.xml

flutter:
  uses-material-design: true
  assets:
    - assets/images/

  fonts:
    - family: Raleway
      fonts:
        - asset: assets/fonts/Raleway-Regular.ttf
        - asset: assets/fonts/Raleway-Italic.ttf
          style: italic
```

## Available Parsers

### Assets

Just follow the doc [Adding assets and images#Specifying assets](https://flutter.dev/docs/development/ui/assets-and-images#specifying-assets) to specify assets, then [FlutterGen] will generate related dart files.  
No other specific configuration is required.  
_Ignore duplicated._

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/images/chip3/chip.jpg
    - assets/images/chip4/chip.jpg
    - assets/images/icons/paint.svg
    - assets/json/fruits.json
    - pictures/ocean_view.jpg
```

These configurations will generate **`assets.gen.dart`** under the **`lib/gen/`** directory by default.

#### Usage Example

[FlutterGen] generates [Image](https://api.flutter.dev/flutter/widgets/Image-class.html) class if the asset is Flutter supported image format.

Example results of `assets/images/chip.jpg`:

- **`Assets.images.chip`** is an implementation of [`AssetImage class`](https://api.flutter.dev/flutter/painting/AssetImage-class.html).
- **`Assets.images.chip.image(...)`** returns [`Image class`](https://api.flutter.dev/flutter/widgets/Image-class.html).
- **`Assets.images.chip.path`** just returns the path string.

```dart
Widget build(BuildContext context) {
  return Image(image: Assets.images.chip);
}

Widget build(BuildContext context) {
  return Assets.images.chip.image(
    width: 120,
    height: 120,
    fit: BoxFit.scaleDown,
  );

Widget build(BuildContext context) {
  // Assets.images.chip.path = 'assets/images/chip3/chip3.jpg'
  return Image.asset(Assets.images.chip.path);
}

```

If you are using SVG images with [flutter_svg](https://pub.dev/packages/flutter_svg) you can use the integration feature.

```yaml
# pubspec.yaml
flutter_gen:

  integrations:
    flutter_svg: true

flutter:
  assets:
    - assets/images/icons/paint.svg
```

```dart
Widget build(BuildContext context) {
  return Assets.images.icons.paint.svg(
    width: 120,
    height: 120
  );
}
```

In other cases, the asset is generated as String class.

```dart
// If don't use the Integrations.
final svg = SvgPicture.asset(Assets.images.icons.paint);

final json = await rootBundle.loadString(Assets.json.fruits);
```

[FlutterGen] also support generating other style of `Assets` class:  

```yaml
# pubspec.yaml
flutter_gen:

  assets:
    # Assets.imagesChip 
    # style: camel-case
    
    # Assets.images_chip
    # style: snake-case

    # Assets.images.chip (default style)
    # style: dot-delimiter

flutter:
  assets:
    - assets/images/chip.png
```

The root directory will be omitted if it is either **`assets`** or **`asset`**.

```
assets/images/chip3/chip.jpg  => Assets.images.chip3.chip
assets/images/chip4/chip.jpg  => Assets.images.chip4.chip
assets/images/icons/paint.svg => Assets.images.icons.paint
assets/json/fruits.json       => Assets.json.fruits
pictures/ocean_view.jpg       => Assets.pictures.oceanView
```

<details><summary>Example of code generated by FlutterGen</summary>
<p>

```dart
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $PicturesGen {
  const $PicturesGen();

  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  AssetGenImage get chip1 => const AssetGenImage('assets/images/chip1.jpg');
  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');
  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();
  $AssetsImagesChip4Gen get chip4 => const $AssetsImagesChip4Gen();
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');
  AssetGenImage get profile => const AssetGenImage('assets/images/profile.jpg');
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  String get fruits => 'assets/json/fruits.json';
}

class $AssetsImagesChip3Gen {
  const $AssetsImagesChip3Gen();

  AssetGenImage get chip3 =>
      const AssetGenImage('assets/images/chip3/chip3.jpg');
}

class $AssetsImagesChip4Gen {
  const $AssetsImagesChip4Gen();

  AssetGenImage get chip4 =>
      const AssetGenImage('assets/images/chip4/chip4.jpg');
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  SvgGenImage get fuchsia =>
      const SvgGenImage('assets/images/icons/fuchsia.svg');
  SvgGenImage get kmm => const SvgGenImage('assets/images/icons/kmm.svg');
  SvgGenImage get paint => const SvgGenImage('assets/images/icons/paint.svg');
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $PicturesGen pictures = $PicturesGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName)
      : _assetName = assetName,
        super(assetName);
  final String _assetName;

  Image image({
    ImageFrameBuilder frameBuilder,
    ImageLoadingBuilder loadingBuilder,
    ImageErrorWidgetBuilder errorBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    bool matchTextDirection = false,
    AssetBundle bundle,
    String package,
    double width,
    double height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder placeholderBuilder,
    Color color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture.asset(
      _assetName,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
    );
  }

  String get path => _assetName;
}

```

</p>
</details>

### Fonts

Just follow the doc [Use a custom font](https://flutter.dev/docs/cookbook/design/fonts) to specify fonts, then [FlutterGen] will generate related dart files.  
No other specific configuration is required.  
_Ignore duplicated._

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Raleway
      fonts:
        - asset: assets/fonts/Raleway-Regular.ttf
        - asset: assets/fonts/Raleway-Italic.ttf
          style: italic
    - family: RobotoMono
      fonts:
        - asset: assets/fonts/RobotoMono-Regular.ttf
        - asset: assets/fonts/RobotoMono-Bold.ttf
          weight: 700
```

These configurations will generate **`fonts.gen.dart`** under the **`lib/gen/`** directory by default.

#### Usage Example

```dart
Text(
  'Hi there, I\'m FlutterGen',
  style: TextStyle(
    fontFamily: FontFamily.robotoMono,
    fontFamilyFallback: const [FontFamily.raleway],
  ),
```

<details><summary>Example of code generated by FlutterGen</summary>
<p>

```dart
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

class FontFamily {
  FontFamily._();

  static const String raleway = 'Raleway';
  static const String robotoMono = 'RobotoMono';
}

```

</p>
</details>

### Colors

[FlutterGen] supports generating colors from [XML](example/assets/color/colors.xml) format files.  
_Ignore duplicated._

```yaml
# pubspec.yaml
flutter_gen:
  colors:
    inputs:
      - assets/color/colors.xml
      - assets/color/colors2.xml
```

[FlutterGen] can generate a [Color](https://api.flutter.dev/flutter/material/Colors-class.html) class based on the `name` attribute and the color hex value.
If the element has the attribute `type`, then a specially color will be generated.

Currently supported special color types:
  - [MaterialColor](https://api.flutter.dev/flutter/material/MaterialColor-class.html)
  - [MaterialAccentColor](https://api.flutter.dev/flutter/material/MaterialAccentColor-class.html)
  
> Noticed that there is no official material color generation algorithm. The implementation is based on the [mcg](https://github.com/mbitson/mcg) project.

```xml
<color name="milk_tea">#F5CB84</color>
<color name="cinnamon" type="material">#955E1C</color>
<color name="yellow_ocher" type="material material-accent">#DF9527</color>
```

These configurations will generate **`colors.gen.dart`** under the **`lib/gen/`** directory by default.

#### Usage Example

```dart
Text(
  'Hi there, I\'m FlutterGen',
  style: TextStyle(
    color: ColorName.denim,
  ),
```

<details><summary>Example of code generated by FlutterGen</summary>
<p>

```dart
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

class ColorName {
  ColorName._();

  static const Color black = Color(0xFF000000);
  static const Color black30 = Color(0x4D000000);
  static const Color black40 = Color(0x66000000);
  static const Color black50 = Color(0x80000000);
  static const Color black60 = Color(0x99000000);
  static const MaterialColor crimsonRed = MaterialColor(
    0xFFCF2A2A,
    <int, Color>{
      50: Color(0xFFF9E5E5),
      100: Color(0xFFF1BFBF),
      200: Color(0xFFE79595),
      300: Color(0xFFDD6A6A),
      400: Color(0xFFD64A4A),
      500: Color(0xFFCF2A2A),
      600: Color(0xFFCA2525),
      700: Color(0xFFC31F1F),
      800: Color(0xFFBD1919),
      900: Color(0xFFB20F0F),
    },
  );
  static const Color gray410 = Color(0xFF979797);
  static const Color gray70 = Color(0xFFEEEEEE);
  static const Color white = Color(0xFFFFFFFF);
  static const MaterialColor yellowOcher = MaterialColor(
    0xFFDF9527,
    <int, Color>{
      50: Color(0xFFFBF2E5),
      100: Color(0xFFF5DFBE),
      200: Color(0xFFEFCA93),
      300: Color(0xFFE9B568),
      400: Color(0xFFE4A547),
      500: Color(0xFFDF9527),
      600: Color(0xFFDB8D23),
      700: Color(0xFFD7821D),
      800: Color(0xFFD27817),
      900: Color(0xFFCA670E),
    },
  );
  static const MaterialAccentColor yellowOcherAccent = MaterialAccentColor(
    0xFFFFBCA3,
    <int, Color>{
      100: Color(0xFFFFE8E0),
      200: Color(0xFFFFBCA3),
      400: Color(0xFFFFA989),
      700: Color(0xFFFF9E7A),
    },
  );
}

```

</p>
</details>

## Credits

The material color generation implementation is based on [mcg](https://github.com/mbitson/mcg) and [TinyColor](https://github.com/bgrins/TinyColor).

## Issues

Please file [FlutterGen] specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FlutterGen/flutter_gen/issues/new).

Plugin issues that are not specific to [FlutterGen] can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

**We are looking for co-developers.**

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/FlutterGen/flutter_gen/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FlutterGen/flutter_gen/pulls).

### Milestone

- [ ] Documentation (English proofreading)
- [x] Assets generation
- [x] Fonts generation
- [x] Colors generation
  - [x] Support xml
- [x] Support change output path
- [x] Support hierarchical generation  
       'assets/image/home/label.png' => Assets.image.home.label  
       'assets/image/detail/label.png' => Assets.image.detail.label
- [ ] Platforms channels generation

[build_runner]: https://pub.dev/packages/build_runner
[fluttergen]: https://pub.dev/packages/flutter_gen
