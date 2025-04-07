import 'package:dart_style/dart_style.dart' show DartFormatter;
import 'package:pub_semver/pub_semver.dart' show VersionConstraint;

import '../settings/config.dart' show Config;

/// The formatter will only use the tall-style if the SDK constraint is ^3.7.
DartFormatter buildDartFormatterFromConfig(Config config) {
  final sdkConstraint = config.pubspec.environment['sdk'];
  final useShort = switch (sdkConstraint) {
    final c? => c.allowsAny(VersionConstraint.parse('<3.7.0')),
    _ => true,
  };
  return DartFormatter(
    languageVersion: useShort
        ? DartFormatter.latestShortStyleLanguageVersion
        : DartFormatter.latestLanguageVersion,
    pageWidth: config.pubspec.flutterGen.lineLength,
    lineEnding: '\n',
  );
}
