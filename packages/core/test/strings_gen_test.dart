import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/strings_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:test/test.dart';

main() {
  group('Test Strings generator', ()
  {
    test('Strings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_strings.yaml');
      final config = loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');
      String fff = generateStrings(pubspec, formatter, config.pubspec.flutterGen.strings);
      // expect(() {
      //   return generateStrings(
      //       pubspec, formatter, config.pubspec.flutterGen.strings);
      // }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}