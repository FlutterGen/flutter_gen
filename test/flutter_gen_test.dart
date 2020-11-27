@TestOn('vm')
import 'dart:io';

import 'package:flutter_gen/src/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Test FlutterGenerator Exceptions', () {
    test('Not founded pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_not_founded.yaml';
      final assets = 'pubspec_not_founded.gen.dart';
      final colors = 'pubspec_not_founded.gen.dart';
      final fonts = 'pubspec_not_founded.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File(colors).existsSync(), isFalse);
    });

    test('Empty pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_empty.yaml';
      final assets = 'pubspec_empty.gen.dart';
      final colors = 'pubspec_empty.gen.dart';
      final fonts = 'pubspec_empty.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File(colors).existsSync(), isFalse);
    });

    test('No settings pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec_no_settings.yaml';
      final assets = 'pubspec_no_settings.gen.dart';
      final colors = 'pubspec_no_settings.gen.dart';
      final fonts = 'pubspec_no_settings.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File(colors).existsSync(), isFalse);
    });
  });

  group('Test FlutterGenerator', () {
    test('pubspec.yaml', () async {
      final yaml = 'test_resources/pubspec.yaml';
      final assets = 'pubspec.gen.dart';
      final colors = 'pubspec.gen.dart';
      final fonts = 'pubspec.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File('test_resources/lib/gen/$assets').readAsStringSync(),
          isNotEmpty);
      expect(
          File('test_resources/lib/gen/$fonts').readAsStringSync(), isNotEmpty);
      expect(File('test_resources/lib/gen/$colors').readAsStringSync(),
          isNotEmpty);
    });

    test('Only flutter value', () async {
      final yaml = 'test_resources/pubspec_only_flutter_value.yaml';
      final assets = 'pubspec_only_flutter_value.gen.dart';
      final colors = 'pubspec_only_flutter_value.gen.dart';
      final fonts = 'pubspec_only_flutter_value.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File('test_resources/lib/gen/$assets').readAsStringSync(),
          isNotEmpty);
      expect(
          File('test_resources/lib/gen/$fonts').readAsStringSync(), isNotEmpty);
      expect(File(colors).existsSync(), isFalse);
    });

    test('Only flutter_gen value', () async {
      final yaml = 'test_resources/pubspec_only_flutter_gen_value.yaml';
      final assets = 'pubspec_only_flutter_gen_value.gen.dart';
      final colors = 'pubspec_only_flutter_gen_value.gen.dart';
      final fonts = 'pubspec_only_flutter_gen_value.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File('test_resources/lib/gen/$colors').readAsStringSync(),
          isNotEmpty);
    });

    test('Change output path', () async {
      final yaml = 'test_resources/pubspec_change_output_path.yaml';
      final assets = 'pubspec_change_output_path.gen.dart';
      final colors = 'pubspec_change_output_path.gen.dart';
      final fonts = 'pubspec_change_output_path.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();

      expect(
          File(
            'test_resources/lib/aaa/bbb/ccc/assets.gen.dart',
          ).readAsStringSync(),
          isNotEmpty);
      expect(
          File(
            'test_resources/lib/aaa/bbb/ccc/fonts.gen.dart',
          ).readAsStringSync(),
          isNotEmpty);
      expect(
          File(
            'test_resources/lib/aaa/bbb/ccc/colors.gen.dart',
          ).readAsStringSync(),
          isNotEmpty);
    });

    test('Wrong output path', () async {
      final yaml = 'test_resources/pubspec_wrong_output_path.yaml';
      final assets = 'pubspec_wrong_output_path.gen.dart';
      final colors = 'pubspec_wrong_output_path.gen.dart';
      final fonts = 'pubspec_wrong_output_path.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File('test_resources/lib/gen/$assets').readAsStringSync(),
          isNotEmpty);
      expect(
          File('test_resources/lib/gen/$fonts').readAsStringSync(), isNotEmpty);
      expect(File('test_resources/lib/gen/$colors').readAsStringSync(),
          isNotEmpty);
    });

    test('Wrong lineLength', () async {
      final yaml = 'test_resources/pubspec_wrong_line_length.yaml';
      final assets = 'pubspec_wrong_line_length.gen.dart';
      final colors = 'pubspec_wrong_line_length.gen.dart';
      final fonts = 'pubspec_wrong_line_length.gen.dart';

      await FlutterGenerator(
        File(yaml),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File('test_resources/lib/gen/$assets').readAsStringSync(),
          isNotEmpty);
      expect(
          File('test_resources/lib/gen/$fonts').readAsStringSync(), isNotEmpty);
      expect(File('test_resources/lib/gen/$colors').readAsStringSync(),
          isNotEmpty);
    });
  });
}
