import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/lottie_integration.dart';
import 'package:flutter_gen_core/generators/integrations/rive_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('Config integration version resolution', () {
    test('resolves versions from pubspec.lock', () {
      final pubspecFile = File(
        'test_resources/pubspec_integration_versions.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Check that versions are resolved from pubspec.lock
      expect(
        config.integrationResolvedVersions[RiveIntegration],
        equals(Version(0, 13, 5)),
      );
      expect(
        config.integrationResolvedVersions[SvgIntegration],
        equals(Version(2, 0, 9)),
      );
      expect(
        config.integrationResolvedVersions[LottieIntegration],
        equals(Version(5, 1, 0)),
      );
    });

    test('resolves version constraints from pubspec.yaml', () {
      final pubspecFile = File(
        'test_resources/pubspec_integration_versions.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Check that constraints are resolved from pubspec.yaml
      expect(
        config.integrationVersionConstraints[RiveIntegration],
        equals(VersionConstraint.parse('^0.13.0')),
      );
      expect(
        config.integrationVersionConstraints[SvgIntegration],
        equals(VersionConstraint.parse('^2.0.0')),
      );
      expect(
        config.integrationVersionConstraints[LottieIntegration],
        equals(VersionConstraint.parse('^5.0.0')),
      );
    });

    test('resolves Rive 0.14.0 versions correctly', () {
      final pubspecFile = File(
        'test_resources/pubspec_integration_versions_rive_014.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Check that Rive 0.14.0+ version is resolved
      expect(
        config.integrationResolvedVersions[RiveIntegration],
        equals(Version(0, 14, 1)),
      );
      expect(
        config.integrationVersionConstraints[RiveIntegration],
        equals(VersionConstraint.parse('^0.14.0')),
      );

      // Check that flutter_svg is also resolved
      expect(
        config.integrationResolvedVersions[SvgIntegration],
        equals(Version(2, 0, 10)),
      );
      expect(
        config.integrationVersionConstraints[SvgIntegration],
        equals(VersionConstraint.parse('>=2.0.0 <3.0.0')),
      );
    });

    test('handles missing pubspec.lock gracefully', () {
      // Use a pubspec without a corresponding .lock file
      final pubspecFile = File(
        'test_resources/pubspec_assets_rive_integrations.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Should have empty or no resolved versions
      // but should not crash
      expect(config, isNotNull);
      expect(config.integrationResolvedVersions, isA<Map>());
      expect(config.integrationVersionConstraints, isA<Map>());
    });

    test('verifies only expected integration types are present', () {
      final pubspecFile = File(
        'test_resources/pubspec_integration_versions.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Verify that only integration types from the registry are in the maps
      for (final key in config.integrationVersionConstraints.keys) {
        expect(
          [RiveIntegration, SvgIntegration, LottieIntegration].contains(key),
          isTrue,
          reason: 'Unexpected integration type: $key',
        );
      }
      
      for (final key in config.integrationResolvedVersions.keys) {
        expect(
          [RiveIntegration, SvgIntegration, LottieIntegration].contains(key),
          isTrue,
          reason: 'Unexpected integration type: $key',
        );
      }
    });

    test('integration versions are used in AssetsGenConfig', () {
      final pubspecFile = File(
        'test_resources/pubspec_integration_versions.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Verify that the resolved versions and constraints are available
      expect(config.integrationResolvedVersions, isNotEmpty);
      expect(config.integrationVersionConstraints, isNotEmpty);

      // Verify they can be passed to generators
      expect(
        config.integrationResolvedVersions[RiveIntegration],
        isA<Version>(),
      );
      expect(
        config.integrationVersionConstraints[RiveIntegration],
        isA<VersionConstraint>(),
      );
    });

    test('version resolution with only constraint and no lock', () {
      // Create a temporary pubspec file without a lock
      final tempDir = Directory.systemTemp.createTempSync('flutter_gen_test');
      try {
        final tempPubspec = File('${tempDir.path}/pubspec.yaml');
        tempPubspec.writeAsStringSync('''
name: test_no_lock
environment:
  sdk: ^3.0.0
dependencies:
  rive: ^0.13.0
flutter_gen:
  output: lib/gen/
  integrations:
    rive: true
flutter:
  assets:
    - assets/
''');

        final config = loadPubspecConfig(tempPubspec);

        // Should have constraint but no resolved version
        expect(
          config.integrationVersionConstraints[RiveIntegration],
          equals(VersionConstraint.parse('^0.13.0')),
        );
        expect(
          config.integrationResolvedVersions[RiveIntegration],
          isNull,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('version resolution with lock but no constraint', () {
      // This tests the case where pubspec.lock has a version
      // but pubspec.yaml doesn't specify a constraint (e.g., path dependency)
      final tempDir = Directory.systemTemp.createTempSync('flutter_gen_test');
      try {
        final tempPubspec = File('${tempDir.path}/pubspec.yaml');
        tempPubspec.writeAsStringSync('''
name: test_lock_only
environment:
  sdk: ^3.0.0
dependencies:
  rive:
    path: ../rive
flutter_gen:
  output: lib/gen/
  integrations:
    rive: true
flutter:
  assets:
    - assets/
''');

        final tempLock = File('${tempDir.path}/pubspec.lock');
        tempLock.writeAsStringSync('''
packages:
  rive:
    dependency: "direct main"
    description:
      path: "../rive"
      relative: true
    source: path
    version: "0.13.5"
sdks:
  dart: ">=3.0.0 <4.0.0"
''');

        final config = loadPubspecConfig(tempPubspec);

        // Should have resolved version but no constraint
        expect(
          config.integrationResolvedVersions[RiveIntegration],
          equals(Version(0, 13, 5)),
        );
        expect(
          config.integrationVersionConstraints[RiveIntegration],
          isNull,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
