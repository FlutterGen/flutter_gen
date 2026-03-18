import 'dart:convert';
import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/lottie_integration.dart';
import 'package:flutter_gen_core/generators/integrations/rive_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/generators/registry.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('Config integration version resolution', () {
    test('resolves versions from pubspec.lock', () {
      final pubspecFile = File(
        'test_resources/integration_versions/pubspec.yaml',
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
        'test_resources/integration_versions/pubspec.yaml',
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
        'test_resources/integration_versions_rive_014/pubspec.yaml',
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
        'test_resources/integration_versions/pubspec.yaml',
      );
      final config = loadPubspecConfig(pubspecFile);

      // Verify that only integration types from the registry are in the maps
      final expectedTypes = integrationPackages.keys.toList();

      for (final key in config.integrationVersionConstraints.keys) {
        expect(
          expectedTypes.contains(key),
          isTrue,
          reason: 'Unexpected integration type: $key',
        );
      }

      for (final key in config.integrationResolvedVersions.keys) {
        expect(
          expectedTypes.contains(key),
          isTrue,
          reason: 'Unexpected integration type: $key',
        );
      }
    });

    test('integration versions are used in AssetsGenConfig', () {
      final pubspecFile = File(
        'test_resources/integration_versions/pubspec.yaml',
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

  group('ConfigLoadInput', () {
    test('ignores a missing explicit build file', () {
      final tempDir = Directory.systemTemp.createTempSync('flutter_gen_test');
      try {
        final tempPubspec = File('${tempDir.path}/pubspec.yaml');
        tempPubspec.writeAsStringSync('''
name: missing_build_file_test
environment:
  sdk: ^3.7.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');

        final config = loadPubspecConfig(
          tempPubspec,
          buildFile: File('${tempDir.path}/missing_build.yaml'),
        );

        expect(config.pubspec.flutterGen.output, equals('lib/gen/'));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('merges builder options and analysis options from direct input', () {
      final config = loadPubspecConfigFromInput(
        ConfigLoadInput(
          pubspecFile: File('/virtual/pkg/pubspec.yaml'),
          pubspecContent: '''
name: input_test
environment:
  sdk: ^3.7.0
dependencies:
  rive: ^0.13.0
flutter_gen:
  output: lib/gen/
  integrations:
    rive: true
flutter:
  assets:
    - assets/images/
''',
          buildOptions: {
            'output': 'lib/build_gen/',
          },
          pubspecLockContent: '''
packages:
  rive:
    version: "0.13.5"
sdks:
  dart: ">=3.7.0 <4.0.0"
''',
          analysisOptionsContent: '''
formatter:
  page_width: 120
''',
        ),
      );

      expect(config.pubspec.flutterGen.output, equals('lib/build_gen/'));
      expect(config.formatterPageWidth, equals(120));
      expect(
        config.integrationResolvedVersions[RiveIntegration],
        equals(Version(0, 13, 5)),
      );
      expect(
        config.integrationVersionConstraints[RiveIntegration],
        equals(VersionConstraint.parse('^0.13.0')),
      );
      expect(config.sdkConstraint, equals(VersionConstraint.parse('^3.7.0')));
    });

    test('falls back to pubspec.lock sdk when pubspec omits sdk', () {
      final config = loadPubspecConfigFromInput(
        ConfigLoadInput(
          pubspecFile: File('/virtual/pkg/pubspec.yaml'),
          pubspecContent: '''
name: lock_sdk_test
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/images/
''',
          pubspecLockContent: '''
sdks:
  dart: ">=3.6.0 <4.0.0"
''',
        ),
      );

      expect(
        config.sdkConstraint,
        equals(VersionConstraint.parse('>=3.6.0 <4.0.0')),
      );
    });

    test('ignores empty builder options in direct input', () {
      final config = loadPubspecConfigFromInput(
        ConfigLoadInput(
          pubspecFile: File('/virtual/pkg/pubspec.yaml'),
          pubspecContent: '''
name: empty_build_options_test
flutter:
  assets:
    - assets/
flutter_gen:
  output: lib/gen/
''',
          buildOptions: const {},
        ),
      );

      expect(config.pubspec.flutterGen.output, equals('lib/gen/'));
    });

    test('returns null for invalid json mapping in direct input', () {
      final config = loadPubspecConfigFromInputOrNull(
        ConfigLoadInput(
          pubspecFile: File('/virtual/pkg/pubspec.yaml'),
          pubspecContent: '''
name: invalid_json_test
environment:
  dart: ^3.7.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''',
        ),
      );

      expect(config, isNull);
    });

    test(
        'returns null when direct input path access throws FileSystemException',
        () {
      final config = loadPubspecConfigFromInputOrNull(
        ConfigLoadInput(
          pubspecFile: _ThrowingFile.parent(
            path: '/virtual/pkg/pubspec.yaml',
            error: const FileSystemException('boom'),
          ),
          pubspecContent: '''
name: file_system_error_test
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''',
        ),
      );

      expect(config, isNull);
    });

    test(
        'returns null when direct input path access throws InvalidSettingsException',
        () {
      final config = loadPubspecConfigFromInputOrNull(
        ConfigLoadInput(
          pubspecFile: _ThrowingFile.parent(
            path: '/virtual/pkg/pubspec.yaml',
            error: const InvalidSettingsException('boom'),
          ),
          pubspecContent: '''
name: invalid_settings_direct_test
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''',
        ),
      );

      expect(config, isNull);
    });
  });

  group('loadPubspecConfigOrNull', () {
    test('returns null when file reading throws InvalidSettingsException', () {
      final config = loadPubspecConfigOrNull(
        _ThrowingFile.read(
          path: '/virtual/pkg/pubspec.yaml',
          error: const InvalidSettingsException('boom'),
        ),
      );

      expect(config, isNull);
    });
  });
}

class _ThrowingFile implements File {
  _ThrowingFile.read({
    required this.path,
    required Object error,
  })  : _readError = error,
        _parentError = null;

  _ThrowingFile.parent({
    required this.path,
    required Object error,
  })  : _parentError = error,
        _readError = null;

  final Object? _readError;
  final Object? _parentError;

  @override
  final String path;

  @override
  Directory get parent {
    if (_parentError case final Object error) {
      throw error;
    }
    return Directory(Uri.file(path).resolve('.').toFilePath());
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    if (_readError case final Object error) {
      throw error;
    }
    return '';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
