import 'dart:io' as io show Platform;

import 'package:dart_style/dart_style.dart' show DartFormatter;
import 'package:pub_semver/pub_semver.dart' show VersionConstraint;

import '../settings/config.dart' show Config;

/// The formatter will only use the tall-style if the SDK constraint is ^3.7.
DartFormatter buildDartFormatterFromConfig(Config config) {
  VersionConstraint? sdkConstraint = config.sdkConstraint;
  if (sdkConstraint == null) {
    final version = io.Platform.version.split(' ').first;
    sdkConstraint = VersionConstraint.parse('^$version');
  }
  final useShort = sdkConstraint.allowsAny(VersionConstraint.parse('<3.7.0'));

  final pageWidth =
      config.pubspec.flutterGen.lineLength ?? config.formatterPageWidth;

  return DartFormatter(
    languageVersion: useShort
        ? DartFormatter.latestShortStyleLanguageVersion
        : DartFormatter.latestLanguageVersion,
    pageWidth: pageWidth,
    // trailingCommas: config.formatterTrailingCommas,
    lineEnding: '\n',
  );
}
