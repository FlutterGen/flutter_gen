import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter_gen_core/generators/assets_generator.dart';
import 'package:flutter_gen_core/generators/generator_helper.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/string.dart';
import 'package:test/test.dart';

import 'gen_test_helper.dart';

void main() {
  group('Test Assets generator', () {
    test('Assets on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets.yaml';
      const fact = 'test_resources/actual_data/assets.gen.dart';
      const generated = 'test_resources/lib/gen/assets.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets snake-case style on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_snake_case.yaml';
      const fact = 'test_resources/actual_data/assets_snake_case.gen.dart';
      const generated = 'test_resources/lib/gen/assets_snake_case.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets camel-case style on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_assets_camel_case.yaml';
      const fact = 'test_resources/actual_data/assets_camel_case.gen.dart';
      const generated = 'test_resources/lib/gen/assets_camel_case.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with Unknown mime type on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_unknown_mime_type.yaml';
      const fact =
          'test_resources/actual_data/assets_unknown_mime_type.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_unknown_mime_type.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with ignore files on pubspec.yaml', () async {
      const pubspec = 'test_resources/pubspec_ignore_files.yaml';
      const fact = 'test_resources/actual_data/assets_ignore_files.gen.dart';
      const generated = 'test_resources/lib/gen/assets_ignore_files.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with No lists on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_no_list.yaml');
      final config = loadPubspecConfig(pubspec);
      final formatter = DartFormatter(
        languageVersion: dartFormatterLanguageVersion,
        pageWidth: config.pubspec.flutterGen.lineLength,
        lineEnding: '\n',
      );

      expect(
        () => generateAssets(
          AssetsGenConfig.fromConfig(pubspec, config),
          formatter,
        ),
        throwsA(isA<InvalidSettingsException>()),
      );
    });

    test('Assets with package parameter enabled', () async {
      const pubspec = 'test_resources/pubspec_assets_package_parameter.yaml';
      const fact =
          'test_resources/actual_data/assets_package_parameter.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_package_parameter.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);

      // The generated classes have `package` fields.
      final content = await File(generated).readAsString();
      expect(content, contains("static const String package = 'test';"));
      expect(
        content,
        contains(
          "@Deprecated('Do not specify package for a generated library asset')",
        ),
      );
      expect(
        content,
        contains('String? package = package,'),
      );
    });

    test('Assets with directory path enabled', () async {
      const pubspec = 'test_resources/pubspec_assets_directory_path.yaml';
      const fact = 'test_resources/actual_data/assets_directory_path.gen.dart';
      const generated = 'test_resources/lib/gen/assets_directory_path.gen.dart';
      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with directory path and package parameter enabled', () async {
      const pubspec =
          'test_resources/pubspec_assets_directory_path_with_package_parameter.yaml';
      const fact =
          'test_resources/actual_data/assets_directory_path_with_package_parameter.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_directory_path_with_package_parameter.gen.dart';
      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with excluded files and directories', () async {
      const pubspec = 'test_resources/pubspec_assets_exclude_files.yaml';
      const fact =
          'test_resources/actual_data/assets_package_exclude_files.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_package_exclude_files.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with change the class name', () async {
      const pubspec = 'test_resources/pubspec_assets_change_class_name.yaml';
      const fact =
          'test_resources/actual_data/assets_change_class_name.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_change_class_name.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with parse metadata enabled', () async {
      const pubspec = 'test_resources/pubspec_assets_parse_metadata.yaml';
      const fact = 'test_resources/actual_data/assets_parse_metadata.gen.dart';
      const generated = 'test_resources/lib/gen/assets_parse_metadata.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with flavored assets', () async {
      const pubspec = 'test_resources/pubspec_assets_flavored.yaml';
      const fact = 'test_resources/actual_data/assets_flavored.gen.dart';
      const generated = 'test_resources/lib/gen/assets_flavored.gen.dart';

      await expectedAssetsGen(pubspec, generated, fact);
    });

    test('Assets with duplicate flavoring entries', () async {
      const pubspec =
          'test_resources/pubspec_assets_flavored_duplicate_entry.yaml';
      const fact =
          'test_resources/actual_data/assets_flavored_duplicate_entry.gen.dart';
      const generated =
          'test_resources/lib/gen/assets_flavored_duplicate_entry.gen.dart';

      await expectLater(
        () => runAssetsGen(pubspec, generated, fact),
        throwsA(isA<StateError>()),
      );
    });

    test('Assets with terrible names (camelCase)', () async {
      // See [AssetTypeIterable.mapToUniqueAssetType] for the rules for picking
      // identifer names.
      final tests = <String, String>{
        'assets/single.jpg': 'single',

        // Two assets with overlapping names
        'assets/logo.jpg': 'logoJpg',
        'assets/logo.png': 'logoPng',

        // Two assets with overlapping names, which when re-written overlaps with a 3rd.
        'assets/profile.jpg': 'profileJpg',
        'assets/profile.png': 'profilePng',
        'assets/profilePng.jpg': 'profilePngJpg',

        // Asset overlapping with a directory name.
        'assets/image': 'image',
        // Directory
        'assets/image.jpg': 'imageJpg',

        // Asset with no base name (but ends up overlapping the previous asset)
        'assets/image/.jpg': 'imageJpg_',

        // Asset with non-ascii names
        // TODO(bramp): Ideally would be 'francais' but that requires a heavy
        // package that can transliterate non-ascii chars.
        'assets/français.jpg': 'franAis',

        // Dart Reserved Words
        // allowed
        'assets/async.png': 'async',
        // allowed
        'assets/abstract.png': 'abstract',
        // must be suffixed (but can use Png)
        'assets/await.png': 'awaitPng',
        // must be suffixed (but can use Png)
        'assets/assert.png': 'assertPng',
        //  must be suffixed
        'assets/await': 'await_',
        // must be suffixed
        'assets/assert': 'assert_',

        // Asset with a number as the first character
        'assets/7up.png': 'a7up',
        'assets/123.png': 'a123',

        // Case gets dropped with CamelCase (can causes conflict)
        'assets/z.png': 'zPng',
        'assets/Z.png': 'zPng_',

        // Case gets corrected.
        'assets/CHANGELOG.md': 'changelog',
      };

      final List<AssetType> assets = tests.keys
          .sorted()
          .map((e) => AssetType(rootPath: '', path: e, flavors: {}))
          .toList();

      final got = assets.mapToUniqueAssetType(camelCase);

      // Expect no duplicates.
      final names = got.map((e) => e.name);
      expect(names.sorted(), tests.values.sorted());
    });

    test(
      'Assets on pubspec_assets.yaml and override with build_assets.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_assets.yaml';
        const build = 'test_resources/build_assets.yaml';
        const fact = 'test_resources/actual_data/build_assets.gen.dart';
        const generated = 'test_resources/lib/build_gen/assets.gen.dart';

        await expectedAssetsGen(pubspec, generated, fact, build: build);
      },
    );

    test(
      'Assets on pubspec_assets.yaml and override with build_runner_assets.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_assets.yaml';
        const build = 'test_resources/build_runner_assets.yaml';
        const fact = 'test_resources/actual_data/build_runner_assets.gen.dart';
        const generated = 'test_resources/lib/build_gen/assets.gen.dart';

        await expectedAssetsGen(pubspec, generated, fact, build: build);
      },
    );

    test(
      'Assets on pubspec_assets.yaml and override with build_empty.yaml ',
      () async {
        const pubspec = 'test_resources/pubspec_assets.yaml';
        const build = 'test_resources/build_empty.yaml';
        const fact = 'test_resources/actual_data/build_empty.gen.dart';
        const generated = 'test_resources/lib/build_gen/assets.gen.dart';

        await expectedAssetsGen(pubspec, generated, fact, build: build);
      },
    );

    test('fallback to build.yaml if valid', () async {
      const pubspec = 'test_resources/pubspec_assets.yaml';
      const fact = 'test_resources/actual_data/build_assets.gen.dart';
      const generated = 'test_resources/lib/build_gen/assets.gen.dart';

      final buildFile = File('build.yaml');
      final originalBuildContent = buildFile.readAsStringSync();
      buildFile.writeAsStringSync(
        File('test_resources/build_assets.yaml').readAsStringSync(),
      );
      await expectedAssetsGen(pubspec, generated, fact).whenComplete(() {
        buildFile.writeAsStringSync(originalBuildContent);
      });
    });
  });

  group('Test generatePackageNameForConfig', () {
    test('Assets on pubspec.yaml', () {
      const pubspec = 'test_resources/pubspec_assets.yaml';
      const fact = null;
      expectedPackageNameGen(pubspec, fact);
    });

    test('Assets with package parameter enabled', () {
      const pubspec = 'test_resources/pubspec_assets_package_parameter.yaml';
      const fact = 'test';
      expectedPackageNameGen(pubspec, fact);
    });
  });

  group('gen helper', () {
    test('build deprecations', () {
      expect(
        sBuildDeprecation(
          'style',
          'asset',
          'asset.output',
          'https://github.com/FlutterGen/flutter_gen/pull/294',
          [
            '  assets:',
            '    outputs:',
            '      style: snake-case',
          ],
        ),
        equals('''
┌─────────────────────────────────────────────────────────────────┐
| ⚠️ Error                                                        |
| The style option has been moved from `asset` to `asset.output`. |
| It should be changed in the `pubspec.yaml`.                     |
| https://github.com/FlutterGen/flutter_gen/pull/294              |
|                                                                 |
| ```yaml                                                         |
| flutter_gen:                                                    |
|   assets:                                                       |
|     outputs:                                                    |
|       style: snake-case                                         |
| ```                                                             |
└─────────────────────────────────────────────────────────────────┘
'''),
      );
    });
  });
}
