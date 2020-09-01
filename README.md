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

```yaml
# pubspec.yaml
```

```dart
// dart
```

### Fonts

```yaml
# pubspec.yaml
```

```dart
// dart
```

### Colors

```yaml
# pubspec.yaml
```

```dart
// dart
```

## Issues

Please file FlutterGen specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to FlutterGen can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

Let's develop together.

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/wasabeef/FlutterGen/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/wasabeef/FlutterGen/pulls).

