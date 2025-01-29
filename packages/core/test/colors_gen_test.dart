import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/settings/color_path.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Color generator', () {
    test('Colors on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_colors.yaml';
      const fact = 'test_resources/actual_data/colors.gen.dart';
      const generated = 'test_resources/lib/gen/colors.gen.dart';

      await expectedColorsGen(pubspec, generated, fact);
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs.yaml');
      final config = loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
        languageVersion: dartFormatterLanguageVersion,
        pageWidth: config.pubspec.flutterGen.lineLength,
        lineEnding: '\n',
      );

      expect(
        () => generateColors(
          pubspec,
          formatter,
          config.pubspec.flutterGen.colors,
        ),
        throwsA(isA<InvalidSettingsException>()),
      );
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs_list.yaml');
      final config = loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
        languageVersion: dartFormatterLanguageVersion,
        pageWidth: config.pubspec.flutterGen.lineLength,
        lineEnding: '\n',
      );

      expect(
        () {
          return generateColors(
            pubspec,
            formatter,
            config.pubspec.flutterGen.colors,
          );
        },
        throwsA(isA<InvalidSettingsException>()),
      );
    });

    test('ColorPath Tests', () async {
      const colorPath = ColorPath('test_resources/assets/color/colors.xml');
      expect(colorPath.mime, 'application/xml');
      expect(colorPath.isXml, isTrue);

      const wrongColorPath = ColorPath('test_resources/assets/json/map.json');
      expect(wrongColorPath.isXml, isFalse);
    });

    test('Change the class name', () async {
      const pubspec = 'test_resources/pubspec_colors_change_class_name.yaml';
      const fact =
          'test_resources/actual_data/colors_change_class_name.gen.dart';
      const generated =
          'test_resources/lib/gen/colors_change_class_name.gen.dart';

      await expectedColorsGen(pubspec, generated, fact);
    });
  });
}
