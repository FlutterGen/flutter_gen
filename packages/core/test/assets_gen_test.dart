@TestOn('vm')
import 'dart:io';

import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/dart_style/dart_style.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Assets generator', () {
    test('Assets on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets.yaml';
      final fact = 'test_resources/actual_data/assets.gen.dart';
      final generated = 'test_resources/lib/gen/assets.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with Disabled Null Safety on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_disable_null_safety.yaml';
      final fact =
          'test_resources/actual_data/assets_disable_null_safety.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_disable_null_safety.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets snake-case style on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_snake_case.yaml';
      final fact = 'test_resources/actual_data/assets_snake_case.gen.dart';
      final generated = 'test_resources/lib/gen/assets_snake_case.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets camel-case style on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_assets_camel_case.yaml';
      final fact = 'test_resources/actual_data/assets_camel_case.gen.dart';
      final generated = 'test_resources/lib/gen/assets_camel_case.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with Unknown mime type on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_unknown_mime_type.yaml';
      final fact =
          'test_resources/actual_data/assets_unknown_mime_type.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_unknown_mime_type.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with ignore files on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_ignore_files.yaml';
      final fact = 'test_resources/actual_data/assets_ignore_files.gen.dart';
      final generated = 'test_resources/lib/gen/assets_ignore_files.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with No lists on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_no_list.yaml');
      final config = await loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateAssets(
            AssetsGenConfig.fromConfig(pubspec, config), formatter);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Assets with package parameter enabled', () async {
      final pubspec = 'test_resources/pubspec_assets_package_parameter.yaml';
      final fact =
          'test_resources/actual_data/assets_package_parameter.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_package_parameter.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with package parameter enabled', () async {
      final pubspec = 'test_resources/pubspec_assets_package_parameter.yaml';
      final fact =
          'test_resources/actual_data/assets_package_parameter_disable_null_safety.gen.dart';
      final generated =
          'test_resources/lib/gen/assets_package_parameter_disable_null_safety.gen.dart';

      expectedAssetsGen(pubspec, generated, fact);
    });
  });
}
