@TestOn('vm')
import 'dart:io';

import 'package:flutter_gen/src/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
  group('Test FlutterGenerator Exceptions', () {
    test('Not founded pubspec.yaml', () async {
      await FlutterGenerator(File('test_resources/pubspec_not_founded.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').existsSync(),
        isFalse,
      );
    });

    test('Empty pubspec.yaml', () async {
      await FlutterGenerator(File('test_resources/pubspec_empty.yaml')).build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').existsSync(),
        isFalse,
      );
    });

    test('No settings pubspec.yaml', () async {
      await FlutterGenerator(File('test_resources/pubspec_no_settings.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').existsSync(),
        isFalse,
      );
    });
  });

  group('Test FlutterGenerator', () {
    test('pubspec.yaml', () async {
      await FlutterGenerator(File('test_resources/pubspec.yaml')).build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Only flutter value', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_only_flutter_value.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').existsSync(),
        isFalse,
      );
    });

    test('Only flutter_gen value', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_only_flutter_gen_value.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Wrong output path', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_wrong_output_path.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Wrong lineLength', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_wrong_line_length.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });
  });
}
