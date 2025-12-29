import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/generators/integrations/lottie_integration.dart';
import 'package:flutter_gen_core/generators/integrations/rive_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

class TestIntegration extends Integration {
  TestIntegration() : super('');

  @override
  String get className => 'TestIntegration';

  @override
  String get classOutput => throw UnimplementedError();

  @override
  bool get isConstConstructor => true;

  @override
  bool isSupport(AssetType asset) {
    return true;
  }

  @override
  List<Import> get requiredImports => [];
}

void main() {
  group('Test Assets Integration generator', () {
    final resPath = p.absolute('test_resources');

    test('Assets with No integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_no_integrations.yaml';
      await expectedAssetsGen(pubspec);
    });

    test('Assets with no image integration', () async {
      const pubspec = 'test_resources/pubspec_assets_no_image_integration.yaml';
      await expectedAssetsGen(pubspec);
    });

    test('Integration.classInstantiate', () {
      expect(
        TestIntegration().classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path',
            flavors: {'test'},
            transformers: {},
          ),
        ),
        'TestIntegration(\'assets/path\', flavors: {\'test\'},)',
      );
    });

    test('Assets with Svg integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_svg_integrations.yaml';
      await expectedAssetsGen(pubspec);

      final integration = SvgIntegration('');
      expect(integration.className, 'SvgGenImage');
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path',
            flavors: {},
            transformers: {},
          ),
        ),
        'SvgGenImage(\'assets/path\')',
      );
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path',
            flavors: {'test'},
            transformers: {},
          ),
        ),
        'SvgGenImage(\'assets/path\', flavors: {\'test\'},)',
      );
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.svg',
            flavors: {},
            transformers: {},
          ),
        ),
        'SvgGenImage(\'assets/path/dog.svg\')',
      );
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.vec',
            flavors: {},
            transformers: {},
          ),
        ),
        'SvgGenImage.vec(\'assets/path/dog.vec\')',
      );
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.svg',
            flavors: {},
            transformers: {'test'},
          ),
        ),
        'SvgGenImage(\'assets/path/dog.svg\')',
      );
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.svg',
            flavors: {},
            transformers: {'vector_graphics_compiler'},
          ),
        ),
        'SvgGenImage.vec(\'assets/path/dog.svg\')',
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.svg',
            flavors: {},
            transformers: {},
          ),
        ),
        isTrue,
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.vec',
            flavors: {},
            transformers: {},
          ),
        ),
        isTrue,
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.svg',
            flavors: {},
            transformers: {'test'},
          ),
        ),
        isTrue,
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.png',
            flavors: {},
            transformers: {},
          ),
        ),
        isFalse,
      );
      expect(integration.isConstConstructor, isTrue);
      expect(integration.classOutput.contains('String? package,'), isTrue);

      final integrationWithPackage = SvgIntegration('package_name');
      expect(
        integrationWithPackage.classOutput.contains(
          'String? package = package,',
        ),
        isTrue,
      );
      expect(
        integrationWithPackage.classOutput.contains(
          "static const String package = 'package_name';",
        ),
        isTrue,
      );
    });

    test('Assets with Rive integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_rive_integrations.yaml';
      await expectedAssetsGen(pubspec);

      final integration = RiveIntegration('');
      expect(integration.className, 'RiveGenImage');
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/path',
            flavors: {},
            transformers: {},
          ),
        ),
        'RiveGenImage(\'assets/path\')',
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.riv',
            flavors: {},
            transformers: {},
          ),
        ),
        isTrue,
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/path/dog.json',
            flavors: {},
            transformers: {},
          ),
        ),
        isFalse,
      );
      expect(integration.isConstConstructor, isTrue);
      expect(integration.classOutput.contains('_assetName,'), isTrue);

      final integrationWithPackage = RiveIntegration('package_name');
      expect(
        integrationWithPackage.classOutput.contains(
          '\'packages/package_name/\$_assetName\',',
        ),
        isTrue,
      );
    });

    test('RiveIntegration version resolution with resolvedVersion', () {
      // Test with version < 0.14.0 (should return RiveIntegrationClassic)
      final classicIntegration = RiveIntegration(
        '',
        resolvedVersion: Version(0, 13, 0),
      );
      expect(classicIntegration, isA<RiveIntegrationClassic>());
      final classicOutput = classicIntegration.classOutput;
      expect(classicOutput.contains('rive({'), isTrue);
      expect(classicOutput.contains('RiveAnimation.asset'), isTrue);
      expect(classicOutput.contains('riveFileLoader'), isFalse);

      // Test with version >= 0.14.0 (should return RiveIntegration0140)
      final latestIntegration = RiveIntegration(
        '',
        resolvedVersion: Version(0, 14, 0),
      );
      expect(latestIntegration, isA<RiveIntegration0140>());
      final latestOutput = latestIntegration.classOutput;
      expect(latestOutput.contains('riveFileLoader({'), isTrue);
      expect(latestOutput.contains('FileLoader.fromAsset'), isTrue);
      expect(latestOutput.contains('rive({'), isFalse);

      // Test with version > 0.14.0
      final newerIntegration = RiveIntegration(
        '',
        resolvedVersion: Version(0, 15, 0),
      );
      expect(newerIntegration, isA<RiveIntegration0140>());
      final newerOutput = newerIntegration.classOutput;
      expect(newerOutput.contains('riveFileLoader({'), isTrue);
    });

    test('RiveIntegration version constraint resolution', () {
      // Test with constraint that allows 0.14.0 (should return RiveIntegration0140)
      final allowsLatest = RiveIntegration(
        '',
        resolvedVersionConstraint: VersionConstraint.parse('^0.14.0'),
      );
      expect(allowsLatest, isA<RiveIntegration0140>());
      expect(allowsLatest.classOutput.contains('riveFileLoader({'), isTrue);

      // Test with constraint that doesn't allow 0.14.0 (should return RiveIntegrationClassic)
      final classicOnly = RiveIntegration(
        '',
        resolvedVersionConstraint: VersionConstraint.parse('>=0.13.0 <0.14.0'),
      );
      expect(classicOnly, isA<RiveIntegrationClassic>());
      expect(classicOnly.classOutput.contains('rive({'), isTrue);

      // Test with constraint like ^0.12.0 (doesn't allow 0.14.0)
      final olderConstraint = RiveIntegration(
        '',
        resolvedVersionConstraint: VersionConstraint.parse('^0.12.0'),
      );
      expect(olderConstraint, isA<RiveIntegrationClassic>());
      expect(olderConstraint.classOutput.contains('rive({'), isTrue);
    });

    test('RiveIntegration version resolution priority', () {
      // resolvedVersion should take priority over resolvedVersionConstraint
      final integration = RiveIntegration(
        '',
        resolvedVersion: Version(0, 13, 0),
        resolvedVersionConstraint: VersionConstraint.parse('^0.14.0'),
      );
      expect(integration, isA<RiveIntegrationClassic>());
      expect(integration.classOutput.contains('rive({'), isTrue);

      // When resolvedVersion is null, fall back to resolvedVersionConstraint
      final fallbackIntegration = RiveIntegration(
        '',
        resolvedVersionConstraint: VersionConstraint.parse('^0.14.0'),
      );
      expect(fallbackIntegration, isA<RiveIntegration0140>());
      expect(fallbackIntegration.classOutput.contains('riveFileLoader({'), isTrue);
    });

    test('RiveIntegration fallback behavior', () {
      // Test with no version information (should return RiveIntegration0140 as fallback)
      final fallbackIntegration = RiveIntegration('');
      expect(fallbackIntegration, isA<RiveIntegration0140>());
      expect(fallbackIntegration.classOutput.contains('riveFileLoader({'), isTrue);
    });

    test('RiveIntegrationClassic classOutput structure', () {
      final integration = RiveIntegrationClassic('');
      final output = integration.classOutput;

      // Check for Classic-specific content
      expect(output.contains('class RiveGenImage {'), isTrue);
      expect(output.contains('final String _assetName;'), isTrue);
      expect(output.contains('final Set<String> flavors;'), isTrue);
      expect(output.contains('rive({'), isTrue);
      expect(output.contains('_rive.RiveAnimation rive({'), isTrue);
      expect(output.contains('_rive.RiveAnimation.asset'), isTrue);
      expect(output.contains('artboard:'), isTrue);
      expect(output.contains('animations:'), isTrue);
      expect(output.contains('stateMachines:'), isTrue);
      expect(output.contains('String get path =>'), isTrue);
      expect(output.contains('String get keyName =>'), isTrue);

      // Ensure it doesn't have 0.14.0+ specific content
      expect(output.contains('riveFileLoader'), isFalse);
      expect(output.contains('FileLoader.fromAsset'), isFalse);
    });

    test('RiveIntegrationClassic classOutput with package', () {
      final integration = RiveIntegrationClassic('test_package');
      final output = integration.classOutput;

      // Check for package-specific content
      expect(
        output.contains("static const String package = 'test_package';"),
        isTrue,
      );
      expect(
        output.contains("'packages/test_package/\$_assetName'"),
        isTrue,
      );
    });

    test('RiveIntegration0140 classOutput structure', () {
      final integration = RiveIntegration0140('');
      final output = integration.classOutput;

      // Check for 0.14.0+ specific content
      expect(output.contains('class RiveGenImage {'), isTrue);
      expect(output.contains('final String _assetName;'), isTrue);
      expect(output.contains('final Set<String> flavors;'), isTrue);
      expect(output.contains('riveFileLoader({'), isTrue);
      expect(output.contains('_rive.FileLoader riveFileLoader({'), isTrue);
      expect(output.contains('_rive.FileLoader.fromAsset'), isTrue);
      expect(output.contains('_rive.Factory? factory,'), isTrue);
      expect(output.contains('riveFactory: factory ?? _rive.Factory.rive'), isTrue);
      expect(output.contains('String get path =>'), isTrue);
      expect(output.contains('String get keyName =>'), isTrue);

      // Ensure it doesn't have Classic-specific content
      expect(output.contains('rive({'), isFalse);
      expect(output.contains('RiveAnimation.asset'), isFalse);
      expect(output.contains('artboard:'), isFalse);
      expect(output.contains('animations:'), isFalse);
      expect(output.contains('stateMachines:'), isFalse);
    });

    test('RiveIntegration0140 classOutput with package', () {
      final integration = RiveIntegration0140('test_package');
      final output = integration.classOutput;

      // Check for package-specific content
      expect(
        output.contains("static const String package = 'test_package';"),
        isTrue,
      );
      expect(
        output.contains("'packages/test_package/\$_assetName'"),
        isTrue,
      );
    });

    test('Assets with Lottie integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_lottie_integrations.yaml';
      await expectedAssetsGen(pubspec);

      final integration = LottieIntegration('');
      expect(integration.className, 'LottieGenImage');
      expect(
        integration.classInstantiate(
          AssetType(
            rootPath: resPath,
            path: 'assets/lottie',
            flavors: {},
            transformers: {},
          ),
        ),
        'LottieGenImage(\'assets/lottie\')',
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/lottie/hamburger_arrow.json',
            flavors: {},
            transformers: {},
          ),
        ),
        isTrue,
      );
      expect(
        integration.isSupport(
          AssetType(
            rootPath: resPath,
            path: 'assets/lottie/hamburger_arrow_without_version.json',
            flavors: {},
            transformers: {},
          ),
        ),
        isFalse,
      );
      expect(integration.isConstConstructor, isTrue);
      expect(integration.classOutput.contains('String? package,'), isTrue);

      final integrationWithPackage = LottieIntegration('package_name');
      expect(
        integrationWithPackage.classOutput.contains(
          'String? package = package,',
        ),
        isTrue,
      );
      expect(
        integrationWithPackage.classOutput.contains(
          "static const String package = 'package_name';",
        ),
        isTrue,
      );
    });
  });
}
