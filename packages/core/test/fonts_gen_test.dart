import 'dart:io';

import 'package:flutter_gen_core/generators/fonts_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/formatter.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Fonts generator', () {
    test('Fonts on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_fonts.yaml';
      await expectedFontsGen(pubspec);
    });

    test('Wrong fonts settings on pubspec.yaml', () async {
      final config = loadPubspecConfig(
        File('test_resources/pubspec_fonts_no_family.yaml'),
      );
      final formatter = buildDartFormatterFromConfig(config);

      expect(
        () => generateFonts(FontsGenConfig.fromConfig(config), formatter),
        throwsA(isA<InvalidSettingsException>()),
      );
    });

    test('Change the class name', () async {
      const pubspec = 'test_resources/pubspec_fonts_change_class_name.yaml';
      await expectedFontsGen(pubspec);
    });

    test('Package parameter enabled', () async {
      const pubspec = 'test_resources/pubspec_fonts_package_parameter.yaml';
      await expectedFontsGen(pubspec);
    });
  });
}
