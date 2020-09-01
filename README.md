<p align="center">
  <img src="./art/logo.png" />
</p>
<p align="center">
  <a href="https://pub.dartlang.org/packages/flutter_gen">
    <img src="https://img.shields.io/pub/v/flutter_gen.svg">
  </a>
  </a>
  <a href="https://github.com/wasabeef/FlutterGen/actions?query=workflow%3A%22Flutter+CI%22">
    <img src="https://github.com/wasabeef/FlutterGen/workflows/Flutter%20CI/badge.svg?branch=master" />
  </a>
</p>

The Flutter code generator for your assets, fonts, colors, localize, … — Get rid of all String-based APIs.

Inspired by [SwiftGen](https://github.com/SwiftGen/SwiftGen).

## Motivation.

When resources such as images are used on Dart code, they are not type-safe.

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/logo.png
```

**Bad**  
What would happen if you made a typo?
```dart
Widget build(BuildContext context) {
  return Image(image: AssetImage('assets/images/logo.png'));
}
```

**Good**  
We need a way to make it safe.
```dart
Widget build(BuildContext context) {
  return Asset.logo.image();
}
```

## Configuration file

All are generated based on [`pubspec.yaml`](https://dart.dev/tools/pub/pubspec).

## Available Parsers

### Assets

### Fonts

### Colors

