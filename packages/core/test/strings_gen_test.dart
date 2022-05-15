@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/strings_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/settings/string_path.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test String generator', () {
    test('Strings on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_strings.yaml';
      const fact = 'test_resources/actual_data/strings.gen.dart';
      const generated = 'test_resources/lib/gen/strings.gen.dart';

      await expectedStringsGen(pubspec, generated, fact);
    });

    test('Wrong strings settings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_strings_no_inputs.yaml');
      final config = await loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateStrings(
            pubspec, formatter, config.pubspec.flutterGen.strings);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Wrong strings settings on pubspec.yaml', () async {
      final pubspec =
          File('test_resources/pubspec_strings_no_inputs_list.yaml');
      final config = await loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateStrings(
            pubspec, formatter, config.pubspec.flutterGen.strings);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('StringPath Tests', () async {
      const stringPath = StringPath('test_resources/assets/strings/en.json');
      expect(stringPath.mime, 'application/json');
      expect(stringPath.isJson, isTrue);

      const wrongStringsPath =
          StringPath('test_resources/assets/strings/en.xml');
      expect(wrongStringsPath.isJson, isFalse);
    });
  });
}
