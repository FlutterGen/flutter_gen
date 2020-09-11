@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/error.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/gen/fonts.gen.dart');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('Test Fonts generator', () {
    test('Fonts on pubspec.yaml', () async {
      final config =
          await Config(File('test_resources/pubspec_fonts.yaml')).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateFonts(formatter, config.flutter.fonts);
      final expected = File('test_resources/actual_data/fonts.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Wrong fonts settings on pubspec.yaml', () async {
      final config =
          await Config(File('test_resources/pubspec_fonts_no_family.yaml'))
              .load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() async {
        return generateFonts(formatter, config.flutter.fonts);
      }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}
