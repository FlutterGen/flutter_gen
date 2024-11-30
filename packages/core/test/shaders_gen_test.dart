import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/generators/shaders_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/settings/shader_type.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Shaders generator', () {
    test('Shaders on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_shaders.yaml';
      const fact = 'test_resources/actual_data/shaders/shaders.gen.dart';
      const generated = 'test_resources/lib/gen/shaders.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders snake-case style on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_shaders_snake_case.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_snake_case.gen.dart';
      const generated = 'test_resources/lib/gen/shaders_snake_case.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders camel-case style on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_shaders_camel_case.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_camel_case.gen.dart';
      const generated = 'test_resources/lib/gen/shaders_camel_case.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with No lists on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_shaders_no_list.yaml');
      final config = loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
          pageWidth: config.pubspec.flutterGen.lineLength, lineEnding: '\n');

      expect(() {
        return generateShaders(
            ShadersGenConfig.fromConfig(pubspec, config), formatter);
      }, throwsA(isA<InvalidSettingsException>()));
    });

    test('Shaders with directory path enabled', () async {
      const pubspec = 'test_resources/pubspec_shaders_directory_path.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_directory_path.gen.dart';
      const generated =
          'test_resources/lib/gen/shaders_directory_path.gen.dart';
      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with excluded files and directories', () async {
      const pubspec = 'test_resources/pubspec_shaders_exclude_files.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_package_exclude_files.gen.dart';
      const generated =
          'test_resources/lib/gen/shaders_package_exclude_files.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with change the class name', () async {
      const pubspec = 'test_resources/pubspec_shaders_change_class_name.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_change_class_name.gen.dart';
      const generated =
          'test_resources/lib/gen/shaders_change_class_name.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with parse metadata enabled', () async {
      const pubspec = 'test_resources/pubspec_shaders_parse_metadata.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_parse_metadata.gen.dart';
      const generated =
          'test_resources/lib/gen/shaders_parse_metadata.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with flavored shaders', () async {
      const pubspec = 'test_resources/pubspec_shaders_flavored.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_flavored.gen.dart';
      const generated = 'test_resources/lib/gen/shaders_flavored.gen.dart';

      await expectedShadersGen(pubspec, generated, fact);
    });

    test('Shaders with duplicate flavoring entries', () async {
      const pubspec =
          'test_resources/pubspec_shaders_flavored_duplicate_entry.yaml';
      const fact =
          'test_resources/actual_data/shaders/shaders_flavored_duplicate_entry.gen.dart';
      const generated =
          'test_resources/lib/gen/shaders_flavored_duplicate_entry.gen.dart';

      await expectLater(
        () => runShadersGen(pubspec, generated, fact),
        throwsA(isA<StateError>()),
      );
    });

    test('Shaders with terrible names (camelCase)', () async {
      // See [ShaderTypeIterable.mapToUniqueShaderType] for the rules for picking
      // identifer names.
      final tests = <String, String>{
        'shaders/single.jpg': 'single',

        // Two shaders with overlapping names
        'shaders/logo.jpg': 'logoJpg',
        'shaders/logo.png': 'logoPng',

        // Two shaders with overlapping names, which when re-written overlaps with a 3rd.
        'shaders/profile.jpg': 'profileJpg',
        'shaders/profile.png': 'profilePng',
        'shaders/profilePng.jpg': 'profilePngJpg',

        // Shader overlapping with a directory name.
        'shaders/image': 'image',
        // Directory
        'shaders/image.jpg': 'imageJpg',

        // Shader with no base name (but ends up overlapping the previous shader)
        'shaders/image/.jpg': 'imageJpg_',

        // Shader with non-ascii names
        // TODO(bramp): Ideally would be 'francais' but that requires a heavy
        // package that can transliterate non-ascii chars.
        'shaders/français.jpg': 'franAis',

        // Dart Reserved Words
        // allowed
        'shaders/async.png': 'async',
        // allowed
        'shaders/abstract.png': 'abstract',
        // must be suffixed (but can use Png)
        'shaders/await.png': 'awaitPng',
        // must be suffixed (but can use Png)
        'shaders/assert.png': 'assertPng',
        //  must be suffixed
        'shaders/await': 'await_',
        // must be suffixed
        'shaders/assert': 'assert_',

        // Shader with a number as the first character
        'shaders/7up.png': 'a7up',
        'shaders/123.png': 'a123',

        // Case gets dropped with CamelCase (can causes conflict)
        'shaders/z.png': 'zPng',
        'shaders/Z.png': 'zPng_',

        // Case gets corrected.
        'shaders/CHANGELOG.md': 'changelog',
      };

      final List<ShaderType> shaders = tests.keys
          .sorted()
          .map((e) => ShaderType(rootPath: '', path: e, flavors: {}))
          .toList();

      final got = shaders.mapToUniqueShaderType(camelCase);

      // Expect no duplicates.
      final names = got.map((e) => e.name);
      expect(names.sorted(), tests.values.sorted());
    });

    test(
      'Shaders on pubspec_shaders.yaml and override with build_assets.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_shaders.yaml';
        const build = 'test_resources/build_assets.yaml';
        const fact =
            'test_resources/actual_data/shaders/build_shaders.gen.dart';
        const generated = 'test_resources/lib/build_gen/shaders.gen.dart';

        await expectedShadersGen(pubspec, generated, fact, build: build);
      },
    );

    test(
      'Shaders on pubspec_shaders.yaml and override with build_runner_assets.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_shaders.yaml';
        const build = 'test_resources/build_runner_assets.yaml';
        const fact =
            'test_resources/actual_data/shaders/build_runner_shaders.gen.dart';
        const generated = 'test_resources/lib/build_gen/shaders.gen.dart';

        await expectedShadersGen(pubspec, generated, fact, build: build);
      },
    );

    test(
      'Shaders on pubspec_shaders.yaml and override with build_empty.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_shaders.yaml';
        const build = 'test_resources/build_empty.yaml';
        const fact = 'test_resources/actual_data/shaders/build_empty.gen.dart';
        const generated = 'test_resources/lib/build_gen/shaders.gen.dart';

        await expectedShadersGen(pubspec, generated, fact, build: build);
      },
    );
  });

  group('Test generatePackageNameForConfig', () {
    test('Shaders on pubspec.yaml', () {
      const pubspec = 'test_resources/pubspec_shaders.yaml';
      const fact = null;
      expectedShadersPackageNameGen(pubspec, fact);
    });

    test('Shaders with package parameter enabled', () {
      const pubspec = 'test_resources/pubspec_shaders_package_parameter.yaml';
      const fact = 'test';
      expectedShadersPackageNameGen(pubspec, fact);
    });
  });
}
