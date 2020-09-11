@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/flutter_generator.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/error.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/gen/assets.gen.dart');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('Test Assets generator', () {
    test('Assets on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected = File('test_resources/actual_data/assets.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets snake-case style on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_snake_case.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_snake_case.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets camel-case style on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_camel_case.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_camel_case.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets with No integrations on pubspec.yaml', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_assets_no_integrations.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );

      final pubspec =
          File('test_resources/pubspec_assets_no_integrations.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_no_integrations.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets with No lists on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_no_list.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      expect(() async {
        return generateAssets(
            pubspec, formatter, config.flutterGen, config.flutter.assets);
      }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}
