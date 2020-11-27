@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Assets generator', () {
    test('Assets on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_assets.yaml';
      final fact = 'test_resources/actual_data/assets.gen.dart';
      final gen = 'test_resources/lib/gen/assets.gen.dart';

      expectedAssetsGen(yaml, gen, fact);
    });

    test('Assets snake-case style on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_assets_snake_case.yaml';
      final fact = 'test_resources/actual_data/assets_snake_case.gen.dart';
      final gen = 'test_resources/lib/gen/assets_snake_case.gen.dart';

      expectedAssetsGen(yaml, gen, fact);
    });

    test('Assets camel-case style on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_assets_camel_case.yaml';
      final fact = 'test_resources/actual_data/assets_camel_case.gen.dart';
      final gen = 'test_resources/lib/gen/assets_camel_case.gen.dart';

      expectedAssetsGen(yaml, gen, fact);
    });

    test('Assets with Unknown mime type on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_unknown_mime_type.yaml';
      final fact =
          'test_resources/actual_data/assets_unknown_mime_type.gen.dart';
      final gen = 'test_resources/lib/gen/assets_unknown_mime_type.gen.dart';

      expectedAssetsGen(yaml, gen, fact);
    });

    test('Assets with ignore files on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_ignore_files.yaml';
      final fact = 'test_resources/actual_data/assets_ignore_files.gen.dart';
      final gen = 'test_resources/lib/gen/assets_ignore_files.gen.dart';

      expectedAssetsGen(yaml, gen, fact);
    });

    test('Assets with No lists on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_no_list.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateAssets(
            pubspec, formatter, config.flutterGen, config.flutter.assets);
      }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}
