import 'dart:io';

import 'package:flutter_gen_core/settings/config.dart';
import 'package:test/test.dart';

void main() {
  group('Test deprecated key', () {
    test('Deprecated lineLength', () async {
      final pubspec = 'test_resources/pubspec_deprecated_line_length.yaml';
      final config = await loadPubspecConfig(File(pubspec));
      expect(config.flutterGen.lineLength, 120);
    });
  });
}
