import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Fonts generator', () {
    test('Fonts on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_fonts.yaml';
      const fact = 'test_resources/actual_data/fonts.gen.dart';
      const generated = 'test_resources/lib/gen/fonts.gen.dart';

      await expectedFontsGen(pubspec, generated, fact);
    });

    test('Wrong fonts settings on pubspec.yaml', () async {
      final config = loadPubspecConfig(
        File('test_resources/pubspec_fonts_no_family.yaml'),
      );
      final formatter = DartFormatter(
        languageVersion: dartFormatterLanguageVersion,
        pageWidth: config.pubspec.flutterGen.lineLength,
        lineEnding: '\n',
      );

      expect(
        () => generateFonts(FontsGenConfig.fromConfig(config), formatter),
        throwsA(isA<InvalidSettingsException>()),
      );
    });

    test('Change the class name', () async {
      const pubspec = 'test_resources/pubspec_fonts_change_class_name.yaml';
      const fact =
          'test_resources/actual_data/fonts_change_class_name.gen.dart';
      const generated =
          'test_resources/lib/gen/fonts_change_class_name.gen.dart';

      await expectedFontsGen(pubspec, generated, fact);
    });

    test('Package parameter enabled', () async {
      const pubspec = 'test_resources/pubspec_fonts_package_parameter.yaml';
      const fact =
          'test_resources/actual_data/fonts_package_parameter.gen.dart';
      const generated =
          'test_resources/lib/gen/fonts_package_parameter.gen.dart';

      await expectedFontsGen(pubspec, generated, fact);
    });
  });
}
