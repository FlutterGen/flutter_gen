@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/error.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/gen/colors.gen.dart');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('Test Color generator', () {
    test('Colors on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual =
          generateColors(pubspec, formatter, config.flutterGen.colors);
      final expected = File('test_resources/actual_data/colors.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() async {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Wrong colors settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors_no_inputs_list.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() async {
        return generateColors(pubspec, formatter, config.flutterGen.colors);
      }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}
