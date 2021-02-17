@TestOn('vm')
import 'dart:io';

import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Test FlutterGenerator Exceptions', () {
    test('Not founded pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_not_founded.yaml';
      final assets = 'pubspec_not_founded_assets.gen.dart';
      final colors = 'pubspec_not_founded_colors.gen.dart';
      final fonts = 'pubspec_not_founded_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File(colors).existsSync(), isFalse);
    });

    test('Empty pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_empty.yaml';
      final assets = 'pubspec_empty_assets.gen.dart';
      final colors = 'pubspec_empty_colors.gen.dart';
      final fonts = 'pubspec_empty_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();
      expect(File(assets).existsSync(), isFalse);
      expect(File(fonts).existsSync(), isFalse);
      expect(File(colors).existsSync(), isFalse);
    });

    test('No settings pubspec.yaml', () async {
      final pubspec = 'test_resources/pubspec_no_settings.yaml';
      final assets = 'pubspec_no_settings_assets.gen.dart';
      final colors = 'pubspec_no_settings_colors.gen.dart';
      final fonts = 'pubspec_no_settings_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
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
      final pubspec = 'test_resources/pubspec.yaml';
      final assets = 'pubspec_assets.gen.dart';
      final colors = 'pubspec_colors.gen.dart';
      final fonts = 'pubspec_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
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
      final pubspec = 'test_resources/pubspec_only_flutter_value.yaml';
      final assets = 'pubspec_only_flutter_value_assets.gen.dart';
      final colors = 'pubspec_only_flutter_value_colors.gen.dart';
      final fonts = 'pubspec_only_flutter_value_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
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
      final pubspec = 'test_resources/pubspec_only_flutter_gen_value.yaml';
      final assets = 'pubspec_only_flutter_gen_value_assets.gen.dart';
      final colors = 'pubspec_only_flutter_gen_value_colors.gen.dart';
      final fonts = 'pubspec_only_flutter_gen_value_colors.gen.dart';

      await FlutterGenerator(
        File(pubspec),
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
      final pubspec = 'test_resources/pubspec_change_output_path.yaml';
      final assets = 'pubspec_change_output_path_assets.gen.dart';
      final colors = 'pubspec_change_output_path_colors.gen.dart';
      final fonts = 'pubspec_change_output_path_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      ).build();

      expect(File('test_resources/lib/aaa/bbb/ccc/$assets').readAsStringSync(),
          isNotEmpty);
      expect(File('test_resources/lib/aaa/bbb/ccc/$colors').readAsStringSync(),
          isNotEmpty);
      expect(File('test_resources/lib/aaa/bbb/ccc/$fonts').readAsStringSync(),
          isNotEmpty);
    });

    test('Empty output path', () async {
      final pubspec = 'test_resources/pubspec_wrong_output_path.yaml';
      final assets = 'pubspec_wrong_output_path_assets.gen.dart';
      final colors = 'pubspec_wrong_output_path_colors.gen.dart';
      final fonts = 'pubspec_wrong_output_path_fonts.gen.dart';

      await FlutterGenerator(
        File(pubspec),
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
      final pubspec = 'test_resources/pubspec_wrong_line_length.yaml';

      expect(() {
        return FlutterGenerator(File(pubspec)).build();
      }, throwsA(isA<Exception>()));
    });

    test('Disabled generation', () async {
      final pubspec = 'test_resources/pubspec_generation_disabled.yaml';
      final assets = 'none_assets.gen.dart';
      final colors = 'none_colors.gen.dart';
      final fonts = 'none_fonts.gen.dart';
      await FlutterGenerator(
        File(pubspec),
        assetsName: assets,
        colorsName: colors,
        fontsName: fonts,
      );
      expect(File('test_resources/lib/gen/$assets').existsSync(), false);
      expect(File('test_resources/lib/gen/$fonts').existsSync(), false);
      expect(File('test_resources/lib/gen/$colors').existsSync(), false);
    });
  });
}
