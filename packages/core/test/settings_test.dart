import 'package:collection/collection.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:flutter_gen_core/settings/flavored_asset.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/error.dart'
    show InvalidSettingsException;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group(AssetType, () {
    test('constructor', () {
      final assetType = AssetType(
        rootPath: 'root',
        path: 'assets/single.jpg',
        flavors: {'flavor'},
        transformers: {'transformer'},
      );
      expect(assetType, isA<AssetType>());
      expect(assetType.name, 'assets/single');
      expect(assetType.baseName, 'single');
      expect(assetType.extension, '.jpg');
      expect(assetType.isUnKnownMime, false);
      expect(
        assetType,
        predicate<AssetType>(
          (e) => const SetEquality().equals(e.flavors, {'flavor'}),
        ),
      );
      expect(
        assetType,
        predicate<AssetType>(
          (e) => const SetEquality().equals(e.transformers, {'transformer'}),
        ),
      );
      expect(
        assetType.toString(),
        'AssetType(rootPath: root, path: assets/single.jpg, '
        'flavors: {flavor}, transformers: {transformer})',
      );
    });
  });

  group(FlavoredAsset, () {
    test('constructor', () {
      expect(
        const FlavoredAsset(path: '').toString(),
        'FlavoredAsset(path: , flavors: {}, transformers: {})',
      );
      expect(
        const FlavoredAsset(path: 'assets/path'),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: 'assets/path', flavors: {}),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: 'assets/path', flavors: {'test'}),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: 'assets/path', transformers: {'test'}),
        isA<FlavoredAsset>(),
      );
      expect(
        const FlavoredAsset(path: '1').copyWith(path: '2'),
        predicate<FlavoredAsset>((e) => e.path == '2'),
      );
      expect(
        const FlavoredAsset(path: '1').copyWith(flavors: {'test'}),
        predicate<FlavoredAsset>(
          (e) => const SetEquality().equals(e.flavors, {'test'}),
        ),
      );
      expect(
        const FlavoredAsset(path: '1').copyWith(transformers: {'test'}),
        predicate<FlavoredAsset>(
          (e) => const SetEquality().equals(e.transformers, {'test'}),
        ),
      );
    });
  });

  group(FlutterGenElementAssetsOutputsStyle, () {
    test('fromJson', () {
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('dot-delimiter'),
        equals(FlutterGenElementAssetsOutputsStyle.dotDelimiterStyle),
      );
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('snake-case'),
        equals(FlutterGenElementAssetsOutputsStyle.snakeCaseStyle),
      );
      expect(
        FlutterGenElementAssetsOutputsStyle.fromJson('camel-case'),
        equals(FlutterGenElementAssetsOutputsStyle.camelCaseStyle),
      );
      expect(
        () => FlutterGenElementAssetsOutputsStyle.fromJson('wrong'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toJson', () {
      for (final style in FlutterGenElementAssetsOutputsStyle.values) {
        expect(style.toJson(), equals(style.name));
      }
    });
  });

  group(InvalidSettingsException, () {
    test('toString', () {
      expect(
        const InvalidSettingsException('message').toString(),
        'InvalidSettingsException: message',
      );
    });
  });

  group('Pubspec.dependenciesVersionConstraint', () {
    test('parses string version constraints', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive: ^0.13.0
  flutter_svg: ^2.0.0
  lottie: ">=1.0.0 <2.0.0"
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      expect(pubspec.dependenciesVersionConstraint['rive'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['rive'],
        equals(VersionConstraint.parse('^0.13.0')),
      );
      
      expect(pubspec.dependenciesVersionConstraint['flutter_svg'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['flutter_svg'],
        equals(VersionConstraint.parse('^2.0.0')),
      );
      
      expect(pubspec.dependenciesVersionConstraint['lottie'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['lottie'],
        equals(VersionConstraint.parse('>=1.0.0 <2.0.0')),
      );
    });

    test('parses map with version key', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive:
    version: ^0.14.0
  flutter_svg:
    version: ">=2.0.0 <3.0.0"
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      expect(pubspec.dependenciesVersionConstraint['rive'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['rive'],
        equals(VersionConstraint.parse('^0.14.0')),
      );
      
      expect(pubspec.dependenciesVersionConstraint['flutter_svg'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['flutter_svg'],
        equals(VersionConstraint.parse('>=2.0.0 <3.0.0')),
      );
    });

    test('handles path dependencies without version', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive:
    path: ../rive
  flutter_svg: ^2.0.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      // Path dependency should be null since no version constraint
      expect(pubspec.dependenciesVersionConstraint['rive'], isNull);
      
      // String version should still work
      expect(pubspec.dependenciesVersionConstraint['flutter_svg'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['flutter_svg'],
        equals(VersionConstraint.parse('^2.0.0')),
      );
    });

    test('handles git dependencies without version', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive:
    git:
      url: https://github.com/example/rive.git
      ref: main
  lottie: ^5.0.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      // Git dependency should be null since no version constraint
      expect(pubspec.dependenciesVersionConstraint['rive'], isNull);
      
      // String version should still work
      expect(pubspec.dependenciesVersionConstraint['lottie'], isNotNull);
      expect(
        pubspec.dependenciesVersionConstraint['lottie'],
        equals(VersionConstraint.parse('^5.0.0')),
      );
    });

    test('handles invalid version strings gracefully', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive: invalid_version
  flutter_svg: ^2.0.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      // Invalid version should be null
      expect(pubspec.dependenciesVersionConstraint['rive'], isNull);
      
      // Valid version should work
      expect(pubspec.dependenciesVersionConstraint['flutter_svg'], isNotNull);
    });

    test('handles dependencies with version key containing invalid version', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive:
    version: invalid_version
  lottie: ^5.0.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      // Invalid version in map should be null
      expect(pubspec.dependenciesVersionConstraint['rive'], isNull);
      
      // Valid string version should work
      expect(pubspec.dependenciesVersionConstraint['lottie'], isNotNull);
    });

    test('handles null dependencies', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      // Should return empty map for null dependencies
      expect(pubspec.dependenciesVersionConstraint, isEmpty);
    });

    test('handles mixed dependency formats', () {
      final yaml = loadYaml('''
name: test
environment:
  sdk: ^3.0.0
dependencies:
  rive: ^0.13.0
  flutter_svg:
    version: ^2.0.0
  lottie:
    path: ../lottie
  another_package:
    git:
      url: https://github.com/example/package.git
flutter_gen:
  output: lib/gen/
flutter:
  assets:
    - assets/
''');
      final pubspec = Pubspec.fromJson(yaml);
      
      expect(
        pubspec.dependenciesVersionConstraint['rive'],
        equals(VersionConstraint.parse('^0.13.0')),
      );
      expect(
        pubspec.dependenciesVersionConstraint['flutter_svg'],
        equals(VersionConstraint.parse('^2.0.0')),
      );
      expect(pubspec.dependenciesVersionConstraint['lottie'], isNull);
      expect(pubspec.dependenciesVersionConstraint['another_package'], isNull);
    });
  });
}
