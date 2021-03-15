@TestOn('vm')
import 'dart:io';

import 'package:flutter_gen_core/generators/colors_generator.dart';
import 'package:flutter_gen_core/settings/color_path.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/dart_style/dart_style.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Color generator', () {
    test('Colors on pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_colors.yaml';
      final fact = 'test_resources/actual_data/colors.gen.dart';
      final generated = 'test_resources/lib/gen/colors.gen.dart';

      expectedColorsGen(pubspec, generated, fact);
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs.yaml');
      final config = await loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs_list.yaml');
      final config = await loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('ColorPath Tests', () async {
      final colorPath = ColorPath('test_resources/assets/color/colors.xml');
      expect(colorPath.mime, 'application/xml');
      expect(colorPath.isXml, isTrue);

      final wrongColorPath =
          ColorPath('test_resources/assets/json/fruits.json');
      expect(wrongColorPath.isXml, isFalse);
    });
  });
}
