@TestOn('vm')
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:flutter_gen/builder.dart';
import 'package:flutter_test/flutter_test.dart';

Directory savedCurrentDirectory;

void main() {
  Builder builder;
  setUp(() => builder = FlutterGenerator());

  group('Test FlutterGenerator', () {
    // test('Empty pubspec.yaml', () async {
    //   await testBuilder(builder, <String, dynamic>{
    //     'example|pubspec.yaml': '',
    //   }, outputs: <String, dynamic>{});
    // });

    test('Only flutter/assets', () async {
      await testBuilder(
        builder,
        <String, dynamic>{
          'example|assets/images/chip1.jpeg': '',
          'example|assets/images/chip2.png': '',
          'example|assets/images/chip3.gif': '',
          'example|assets/images/chip4.bmp': '',
          'example|assets/images/chip5.wbmp': '',
          'example|assets/images/chip5.webp': '',
          'example|assets/json/fruits.json': '',
          'example|pubspec.yaml': '''
          flutter:
            assets:
              - assets/images
              - assets/images/chip1.jpeg
              - assets/images/chip11.jpg
              - assets/images/chip2.png
              - assets/images/chip3.gif
              - assets/images/chip4.wbmp
              - assets/images/chip5.webp
              - assets/images/chip6.svg
              - assets/json/fruits.json
              - assets/json/anim.mp3
          ''',
        },
        generateFor: {
          'example|lib/\$lib\$',
        },
        outputs: <String, dynamic>{
          'example|lib/gen/asset.gen.dart': decodedMatches(allOf([
            contains(
                'static AssetGenImage chip1 = const AssetGenImage(\'assets/images/chip1.jpeg\');\n'),
            contains(
                'static AssetGenImage chip11 = const AssetGenImage(\'assets/images/chip11.jpg\');\n'),
            contains(
                'static AssetGenImage chip2 = const AssetGenImage(\'assets/images/chip2.png\');\n'),
            contains(
                'static AssetGenImage chip3 = const AssetGenImage(\'assets/images/chip3.gif\');\n'),
            contains(
                'static AssetGenImage chip4 = const AssetGenImage(\'assets/images/chip4.wbmp\');\n'),
            contains(
                'static AssetGenImage chip5 = const AssetGenImage(\'assets/images/chip5.webp\');\n'),
            contains(
                'static const String chip6 = \'assets/images/chip6.svg\';\n'),
            contains(
                'static const String fruits = \'assets/json/fruits.json\';\n'),
            contains('static const String anim = \'assets/json/anim.mp3\';\n'),
          ])),
        },
      );
    });

    test('Only flutter/fonts', () async {
      await testBuilder(
        builder,
        <String, dynamic>{
          'example|pubspec.yaml': '''
          flutter:
            fonts:
              - family: Raleway
                fonts:
                  - asset: assets/fonts/Raleway-Regular.ttf
                  - asset: assets/fonts/Raleway-Italic.ttf
                    style: italic
              - family: RobotoMono
                fonts:
                  - asset: assets/fonts/RobotoMono-Regular.ttf
                  - asset: assets/fonts/RobotoMono-Bold.ttf
                    weight: 700
          ''',
        },
        generateFor: {
          'example|lib/\$lib\$',
        },
        outputs: <String, dynamic>{
          'example|lib/gen/font.gen.dart': decodedMatches(allOf([
            contains('static const String raleway = \'Raleway\';\n'),
            contains('static const String robotoMono = \'RobotoMono\';\n'),
          ])),
        },
      );
    });
  });
}

// Matcher _equalsTextWithoutWhitespace(String expected) =>
//     decodedMatches(_IgnoringNewlinesAndWhitespaceMatcher(expected));
//
// class _IgnoringNewlinesAndWhitespaceMatcher extends Matcher {
//   _IgnoringNewlinesAndWhitespaceMatcher(String expected)
//       : _expected = _stripWhitespaceAndNewlines(expected);
//
//   final String _expected;
//
//   @override
//   Description describe(Description description) => description;
//
//   @override
//   bool matches(item, Map matchState) {
//     if (item is! String) {
//       return false;
//     }
//     return _stripWhitespaceAndNewlines(item as String) == _expected;
//   }
// }
//
// String _stripWhitespaceAndNewlines(String original) =>
//     original.replaceAll('\n', '').replaceAll(' ', '');
