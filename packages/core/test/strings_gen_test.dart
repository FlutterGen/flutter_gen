import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen_core/generators/strings_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:test/test.dart';

main() {
  group('Test Strings generator', ()
  {
    test('Strings on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_strings.yaml');
      final config = loadPubspecConfig(pubspec);
      expect(config.pubspec.flutterGen.strings != null, true, reason: 'config.pubspec.flutterGen.strings was null');
      var flutterGenStrings = config.pubspec.flutterGen.strings!;
      final formatter = DartFormatter(pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');
      final genStrings = generateStrings(pubspec, formatter, flutterGenStrings);
      print('genStrings -> $genStrings');
      // expect(() {
      //   return generateStrings(
      //       pubspec, formatter, flutterGenStrings);
      // }, throwsA(isA<InvalidSettingsException>()));
    });
  });
}