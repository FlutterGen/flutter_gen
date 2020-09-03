import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/flutter_generator.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:test/test.dart';

Directory savedCurrentDirectory;

@TestOn('vm')
void main() {
  group('Test FlutterGenerator incorrect case', () {
    test('Not founded pubspec.yaml', () async {
      expect(() async {
        return await FlutterGenerator(
                File('test_resources/pubspec_not_founded.yaml'))
            .build();
      }, throwsA(isA<FileSystemException>()));
    });

    test('Empty pubspec.yaml', () async {
      expect(() async {
        return await FlutterGenerator(File('test_resources/pubspec_empty.yaml'))
            .build();
      }, throwsFormatException);
    });

    test('No settings pubspec.yaml', () async {
      expect(() async {
        return await FlutterGenerator(
                File('test_resources/pubspec_no_settings.yaml'))
            .build();
      }, throwsFormatException);
    });
  });

  group('Test FlutterGenerator correct case', () {
    test('Assets on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(pageWidth: config.flutterGen.lineLength);

      final actual =
          AssetsGenerator.generate(pubspec, formatter, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets.gen.dart').readAsStringSync();

      expect(actual, expected);
    });

    test('Fonts on pubspec.yaml', () async {
      final config =
          await Config(File('test_resources/pubspec_fonts.yaml')).load();
      final formatter = DartFormatter(pageWidth: config.flutterGen.lineLength);

      final actual = FontsGenerator.generate(formatter, config.flutter.fonts);
      final expected =
          File('test_resources/actual_data/fonts.gen.dart').readAsStringSync();

      expect(actual, expected);
    });

    test('Colors on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(pageWidth: config.flutterGen.lineLength);

      final actual = ColorsGenerator.generate(
          pubspec, formatter, config.flutterGen.colors);
      final expected =
          File('test_resources/actual_data/colors.gen.dart').readAsStringSync();

      expect(actual, expected);
    });
  });
}
