import 'package:test/test.dart';

import 'gen_test_helper.dart';

main() {
  group('Test Strings generator', () {
    test('Strings on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_strings_from_yaml.yaml';
      const fact = 'test_resources/actual_data/strings-yaml.gen.dart';
      const generated = 'test_resources/lib/gen/strings-yaml.gen.dart';

      await expectedStringsGen(pubspec, generated, fact);
    });

    test('Strings from XML file specified in pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_strings_from_xml.yaml';
      const fact = 'test_resources/actual_data/strings-xml.gen.dart';
      const generated = 'test_resources/lib/gen/strings-xml.gen.dart';

      await expectedStringsGen(pubspec, generated, fact);
    });

    // test('Strings on pubspec.yaml', () async {
    //   final pubspec = File('test_resources/pubspec_strings_from_yaml.yaml');
    //   final config = loadPubspecConfig(pubspec);
    //   expect(config.pubspec.flutterGen.strings != null, true, reason: 'config.pubspec.flutterGen.strings was null');
    //   var flutterGenStrings = config.pubspec.flutterGen.strings!;
    //   final formatter = DartFormatter(pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');
    //   final genStrings = generateStrings(pubspec, formatter, flutterGenStrings);
    // });
  });
}