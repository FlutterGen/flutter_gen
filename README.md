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
  <a href="https://pub.dev/packages/flutter_lints">
    <img src="https://img.shields.io/badge/style-flutter__lints-40c4ff.svg" />
  </a>
</p>

The Flutter code generator for your assets, fonts, colors, … — Get rid of all String-based APIs.

Inspired by [SwiftGen](https://github.com/SwiftGen/SwiftGen).

## Motivation

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

### Homebrew

Works with macOS and Linux.

```sh
$ brew install FlutterGen/tap/fluttergen
```

### Pub Global

Works with macOS, Linux and Windows.

```sh
$ dart pub global activate flutter_gen
```

You might need to [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

### As a part of build_runner

1. Add [build_runner] and [FlutterGen] to your package's pubspec.yaml file:

```
dev_dependencies:
  build_runner:
  flutter_gen_runner:
```

2. Install [FlutterGen]

```sh
$ flutter pub get
```

3. Use [FlutterGen]

```
$ flutter packages pub run build_runner build
```

## Usage

Run `fluttergen` after the configuration [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec).

```sh
$ fluttergen -h

$ fluttergen -c example/pubspec.yaml
```

## Configuration file

[FlutterGen] generates dart files based on the key **`flutter`** and **`flutter_gen`** of [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec).  
Default configuration can be found [here](https://github.com/FlutterGen/flutter_gen/tree/main/packages/core/lib/settings/config_default.dart). 

```yaml
# pubspec.yaml
# ...

flutter_gen:
  output: lib/gen/ # Optional (default: lib/gen/)
  line_length: 80 # Optional (default: 80)

  # Optional
  integrations:
    flutter_svg: true
    flare_flutter: true
    rive: true
    lottie: true
    # To use "vector_graphics", "flutter_svg" also must be enabled
    vector_graphics: true

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
    - assets/images/icons/dart@test.svg
    - assets/images/icons/dart@test.svg.vec
    - assets/json/fruits.json
    - assets/flare/Penguin.flr
    - assets/rive/vehicles.riv
    - pictures/ocean_view.jpg
```

These configurations will generate **`assets.gen.dart`** under the **`lib/gen/`** directory by default.

#### Usage Example

[FlutterGen] generates [Image](https://api.flutter.dev/flutter/widgets/Image-class.html) class if the asset is Flutter supported image format.

Example results of `assets/images/chip.jpg`:

- **`Assets.images.chip`** is an implementation of [`AssetImage class`](https://api.flutter.dev/flutter/painting/AssetImage-class.html).
- **`Assets.images.chip.image(...)`** returns [`Image class`](https://api.flutter.dev/flutter/widgets/Image-class.html).
- **`Assets.images.chip.provider(...)`** returns [`ImageProvider class`](https://api.flutter.dev/flutter/painting/ImageProvider-class.html).
- **`Assets.images.chip.path`** just returns the path string.
- **`Assets.images.chip.values`** just returns the values list.

```dart
Widget build(BuildContext context) {
  return Assets.images.chip.image();
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

If you are using SVG images with [flutter_svg][] you can use the integration feature.

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

You can use [vector_graphics][] integration as well as [flutter_svg][], which
is an optimized parser of SVG images pre-compiled by [vector_graphics_compiler][].
For more information, see also [the instruction manual][precompiling-and-optimizing-svgs].

```yaml
# pubspec.yaml
flutter_gen:
  integrations:
    # To use "vector_graphics", "flutter_svg" also must be enabled
    flutter_svg: true
    vector_graphics: true

flutter:
  assets:
    # `flutter_gen` consider files ending with the `.vec` extension
    # as `vector_graphics`-compatible files.
    - assets/images/icons/paint.vec
```

```dart
Widget build(BuildContext context) {
  return Assets.images.icons.paint.svg(
    width: 120,
    height: 120
  );
}
```

**Available Integrations**

|Packages|File extension|Setting|Usage|
|--|--|--|--|
|[flutter_svg][]|.svg| `flutter_svg: true` |Assets.images.icons.paint.**svg()**|
|[flare_flutter](https://pub.dev/packages/flare_flutter)|.flr| `flare_flutter: true` |Assets.flare.penguin.**flare()**|
|[rive](https://pub.dev/packages/rive)|.flr| `rive: true` |Assets.rive.vehicles.**rive()**|
|[lottie](https://pub.dev/packages/lottie)|.json| `lottie: true` |Assets.lottie.hamburgerArrow.**lottie()**|
|[vector_graphics]|.svg.vec *or* .vec| `vector_graphics: true` |Assets.images.icons.paint.**svg()**|


<br/>

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
    outputs: 
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
assets/images/chip3/chip.jpg      => Assets.images.chip3.chip
assets/images/chip4/chip.jpg      => Assets.images.chip4.chip
assets/images/icons/paint.svg     => Assets.images.icons.paint
assets/images/icons/dart@test.svg => Assets.images.icons.dartTest
assets/json/fruits.json           => Assets.json.fruits
pictures/ocean_view.jpg           => Assets.pictures.oceanView
```

[Example of code generated by FlutterGen](https://github.com/FlutterGen/flutter_gen/tree/main/example/lib/gen/assets.gen.dart)

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

[Example of code generated by FlutterGen](https://github.com/FlutterGen/flutter_gen/tree/main/example/lib/gen/fonts.gen.dart)

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

[Example of code generated by FlutterGen](https://github.com/FlutterGen/flutter_gen/tree/main/example/lib/gen/colors.gen.dart)

## Credits

The material color generation implementation is based on [mcg](https://github.com/mbitson/mcg) and [TinyColor](https://github.com/bgrins/TinyColor).

## Issues

Please file [FlutterGen] specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FlutterGen/flutter_gen/issues/new).

Plugin issues that are not specific to [FlutterGen] can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

### Known Issues
#### Bad State: No Element when using build_runner
If you get an error message like this:
```
[SEVERE] flutter_gen_runner:flutter_gen_runner on $package$:

Bad state: No element
[SEVERE] Failed after 16.0s
```

The you most likely have a customized `build.yaml` to configure the build runner. In that case, all you have to do is to add the `pubspec.yaml` as build source to your `build.yaml`

```yaml
targets:
  $default:
    sources:
      include:
        - pubspec.yaml  # add this line
        - ...
```

See #268 for the corresponding issue discussion.

### Error with [internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

Please try to remove `generate: true` in your `pubspec.yaml` and disable `synthetic-package` in your `l10n.yaml` like:

```yaml
# pubspec.yaml
flutter:
  generate: true <--- ⚠️Remove this line⚠️
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: false <--- ⚠️Add this line⚠️
```

If you get 

## Contributing

**We are looking for co-developers.**

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/FlutterGen/flutter_gen/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FlutterGen/flutter_gen/pulls).

[build_runner]: https://pub.dev/packages/build_runner
[fluttergen]: https://pub.dev/packages/flutter_gen
[flutter_svg]: https://pub.dev/packages/flutter_svg
[precompiling-and-optimizing-svgs]: https://pub.dev/packages/flutter_svg#precompiling-and-optimizing-svgs
[vector_graphics]: https://pub.dev/packages/vector_graphics
[vector_graphics_compiler]: https://pub.dev/packages/vector_graphics_compiler
