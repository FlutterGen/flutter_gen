import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/generators/integrations/lottie_integration.dart';
import 'package:flutter_gen_core/generators/integrations/rive_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:path/path.dart' as p;
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
