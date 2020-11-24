@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/flutter_generator.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/integrations/flare_integration.dart';
import 'package:flutter_gen/src/generators/integrations/svg_integration.dart';
import 'package:flutter_gen/src/settings/asset_type.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/gen/assets.gen.dart');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  test('Assets with No integrations on pubspec.yaml', () async {
    await FlutterGenerator(
            File('test_resources/pubspec_assets_no_integrations.yaml'))
        .build();
    expect(
      File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
      isNotEmpty,
    );

    final pubspec = File('test_resources/pubspec_assets_no_integrations.yaml');
    final config = await Config(pubspec).load();
    final formatter = DartFormatter(
        pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

    final actual = generateAssets(
        pubspec, formatter, config.flutterGen, config.flutter.assets);
    final expected =
        File('test_resources/actual_data/assets_no_integrations.gen.dart')
            .readAsStringSync()
            .replaceAll('\r\n', '\n');

    expect(actual, expected);
  });

  test('Assets with Svg integrations on pubspec.yaml', () async {
    await FlutterGenerator(
            File('test_resources/pubspec_assets_svg_integrations.yaml'))
        .build();
    expect(
      File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
      isNotEmpty,
    );

    final pubspec = File('test_resources/pubspec_assets_svg_integrations.yaml');
    final config = await Config(pubspec).load();
    final formatter = DartFormatter(
        pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

    final actual = generateAssets(
        pubspec, formatter, config.flutterGen, config.flutter.assets);
    final expected =
        File('test_resources/actual_data/assets_svg_integrations.gen.dart')
            .readAsStringSync()
            .replaceAll('\r\n', '\n');

    expect(actual, expected);

    final integration = SvgIntegration();
    expect(integration.className, 'SvgGenImage');
    expect(integration.classInstantiate('assets/path'),
        'SvgGenImage\(\'assets/path\'\)');
    expect(integration.isSupport(AssetType('assets/path/dog.svg')), isTrue);
    expect(integration.isSupport(AssetType('assets/path/dog.png')), isFalse);
    expect(integration.isConstConstructor, isTrue);
  });

  test('Assets with Flare integrations on pubspec.yaml', () async {
    await FlutterGenerator(
            File('test_resources/pubspec_assets_flare_integrations.yaml'))
        .build();
    expect(
      File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
      isNotEmpty,
    );

    final pubspec =
        File('test_resources/pubspec_assets_flare_integrations.yaml');
    final config = await Config(pubspec).load();
    final formatter = DartFormatter(
        pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

    final actual = generateAssets(
        pubspec, formatter, config.flutterGen, config.flutter.assets);
    final expected =
        File('test_resources/actual_data/assets_flare_integrations.gen.dart')
            .readAsStringSync()
            .replaceAll('\r\n', '\n');

    expect(actual, expected);

    final integration = FlareIntegration();
    expect(integration.className, 'FlareGenImage');
    expect(integration.classInstantiate('assets/path'),
        'FlareGenImage\(\'assets/path\'\)');
    expect(integration.isSupport(AssetType('assets/path/dog.flr')), isTrue);
    expect(integration.isSupport(AssetType('assets/path/dog.json')), isFalse);
    expect(integration.isConstConstructor, isTrue);
  });
}
