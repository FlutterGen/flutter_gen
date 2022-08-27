@TestOn('vm')
import 'package:flutter_gen_core/generators/integrations/flare_integration.dart';
import 'package:flutter_gen_core/generators/integrations/lottie_integration.dart';
import 'package:flutter_gen_core/generators/integrations/rive_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'gen_test_helper.dart';

void main() {
  group('Test Assets Integration generator', () {
    final resPath = p.absolute('test_resources');
    test('Assets with No integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_no_integrations.yaml';
      const fact = 'test_resources/actual_data/assets_no_integrations.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_no_integrations.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with Svg integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_svg_integrations.yaml';
      const fact =
          'test_resources/actual_data/assets_svg_integrations.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_svg_integrations.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);

      final integration = SvgIntegration('package_name');
      expect(integration.className, 'SvgGenImage');
      expect(integration.classInstantiate('assets/path'),
          'SvgGenImage(\'assets/path\')');
      expect(integration.isSupport(AssetType('assets/path/dog.svg', resPath)),
          isTrue);
      expect(integration.isSupport(AssetType('assets/path/dog.png', resPath)),
          isFalse);
      expect(integration.isConstConstructor, isTrue);
    });

    test('Assets with Flare integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_flare_integrations.yaml';
      const fact =
          'test_resources/actual_data/assets_flare_integrations.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_flare_integrations.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);

      final integration = FlareIntegration();
      expect(integration.className, 'FlareGenImage');
      expect(integration.classInstantiate('assets/path'),
          'FlareGenImage(\'assets/path\')');
      expect(integration.isSupport(AssetType('assets/path/dog.flr', resPath)),
          isTrue);
      expect(integration.isSupport(AssetType('assets/path/dog.json', resPath)),
          isFalse);
      expect(integration.isConstConstructor, isTrue);
    });

    test('Assets with Rive integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_rive_integrations.yaml';
      const fact =
          'test_resources/actual_data/assets_rive_integrations.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_rive_integrations.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);

      final integration = RiveIntegration();
      expect(integration.className, 'RiveGenImage');
      expect(integration.classInstantiate('assets/path'),
          'RiveGenImage(\'assets/path\')');
      expect(integration.isSupport(AssetType('assets/path/dog.riv', resPath)),
          isTrue);
      expect(integration.isSupport(AssetType('assets/path/dog.json', resPath)),
          isFalse);
      expect(integration.isConstConstructor, isTrue);
    });

    test('Assets with Lottie integrations on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_lottie_integrations.yaml';
      const fact =
          'test_resources/actual_data/assets_lottie_integrations.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_lottie_integrations.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);

      final integration = LottieIntegration();
      expect(integration.className, 'LottieGenImage');
      expect(integration.classInstantiate('assets/lottie'),
          'LottieGenImage(\'assets/lottie\')');
      expect(
          integration.isSupport(
              AssetType('assets/lottie/hamburger_arrow.json', resPath)),
          isTrue);
      expect(
          integration.isSupport(AssetType(
              'assets/lottie/hamburger_arrow_without_version.json', resPath)),
          isFalse);
      expect(integration.isConstConstructor, isTrue);
    });
  });
}
