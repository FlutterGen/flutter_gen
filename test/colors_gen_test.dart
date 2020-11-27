@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Color generator', () {
    test('Colors on pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_colors.yaml';
      final fact = 'test_resources/actual_data/colors.gen.dart';
      final gen = 'test_resources/lib/gen/colors.gen.dart';

      expectedColorsGen(yaml, gen, fact);
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs_list.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}
