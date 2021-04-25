import 'dart:io';

@TestOn('vm')
import 'package:flutter_gen_core/generators/integrations/flare_integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Assets Integration generator', () {
    test('Assets with No integrations on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_no_integrations.yaml';
      final fact = 'test_resources/actual_data/assets_no_integrations.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_no_integrations.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with Svg integrations on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_svg_integrations.yaml';
      final fact =
          'test_resources/actual_data/assets_svg_integrations.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_svg_integrations.gen.dart';
      final config = await loadPubspecConfig(File(pubspec));

      expectedAssetsGen(pubspec, generated, fact);

      final integration = SvgIntegration('package_name',
          nullSafety: config.flutterGen.nullSafety);
      expect(integration.className, 'SvgGenImage');
      expect(integration.classInstantiate('assets/path'),
          'SvgGenImage\(\'assets/path\'\)');
      expect(integration.isSupport(AssetType('assets/path/dog.svg')), isTrue);
      expect(integration.isSupport(AssetType('assets/path/dog.png')), isFalse);
      expect(integration.isConstConstructor, isTrue);
    });

    test('Assets with Flare integrations on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_flare_integrations.yaml';
      final fact =
          'test_resources/actual_data/assets_flare_integrations.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_flare_integrations.gen.dart';
      final config = await loadPubspecConfig(File(pubspec));

      expectedAssetsGen(pubspec, generated, fact);

      final integration =
          FlareIntegration(nullSafety: config.flutterGen.nullSafety);
      expect(integration.className, 'FlareGenImage');
      expect(integration.classInstantiate('assets/path'),
          'FlareGenImage\(\'assets/path\'\)');
      expect(integration.isSupport(AssetType('assets/path/dog.flr')), isTrue);
      expect(integration.isSupport(AssetType('assets/path/dog.json')), isFalse);
      expect(integration.isConstConstructor, isTrue);
    });
  });
}
