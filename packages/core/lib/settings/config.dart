import 'dart:io';

// import 'package:collection/collection.dart';
// import 'package:dart_style/dart_style.dart' show TrailingCommas;
import 'package:flutter_gen_core/settings/config_default.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/cast.dart' show safeCast;
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:flutter_gen_core/utils/map.dart';
import 'package:flutter_gen_core/version.gen.dart';
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart' show VersionConstraint;
import 'package:yaml/yaml.dart';

class Config {
  const Config._({
    required this.pubspec,
    required this.pubspecFile,
    required this.sdkConstraint,
    // required this.formatterTrailingCommas,
    required this.formatterPageWidth,
  });

  final Pubspec pubspec;
  final File pubspecFile;
  final VersionConstraint? sdkConstraint;

  // TODO(ANYONE): Allow passing the trailing commas option after the SDK constraint was bumped to ^3.7.
  // final TrailingCommas? formatterTrailingCommas;

  final int? formatterPageWidth;
}

Config loadPubspecConfig(File pubspecFile, {File? buildFile}) {
  final pubspecLocaleHint = normalize(
    join(basename(pubspecFile.parent.path), basename(pubspecFile.path)),
  );

  log.info('v$packageVersion Loading ...');
  log.info('Reading options from $pubspecLocaleHint');

  VersionConstraint? sdkConstraint;

  final defaultMap = loadYaml(configDefaultYamlContent) as YamlMap?;

  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspecMap = loadYaml(pubspecContent) as YamlMap?;
  if (safeCast<String>(pubspecMap?['environment']?['sdk']) case final sdk?) {
    sdkConstraint = VersionConstraint.parse(sdk);
  }

  Map mergedMap = mergeMap([defaultMap, pubspecMap]);

  YamlMap? getBuildFileOptions(File file) {
    if (!file.existsSync()) {
      return null;
    }
    final buildContent = file.readAsStringSync();
    final rawMap = loadYaml(buildContent) as Map?;
    final builders = rawMap?['targets']?[r'$default']?['builders'];
    final optionBuildMap = (builders?['flutter_gen_runner'] ??
        builders?['flutter_gen'])?['options'];
    if (optionBuildMap is YamlMap && optionBuildMap.isNotEmpty) {
      return optionBuildMap;
    }
    return null;
  }

  // Fallback to the build.yaml when no build file has been specified and
  // the default one has valid configurations.
  if (buildFile == null && getBuildFileOptions(File('build.yaml')) != null) {
    buildFile = File('build.yaml');
  }

  if (buildFile != null) {
    if (buildFile.existsSync()) {
      final optionBuildMap = getBuildFileOptions(buildFile);
      if (optionBuildMap != null) {
        final buildMap = {'flutter_gen': optionBuildMap};
        mergedMap = mergeMap([mergedMap, buildMap]);
        final buildLocaleHint = normalize(
          join(basename(buildFile.parent.path), basename(buildFile.path)),
        );
        log.info('Reading options from $buildLocaleHint');
      } else {
        log.severe(
          'Specified ${buildFile.path} as input but the file '
          'does not contain valid options, ignoring...',
        );
      }
    } else {
      log.warning(
        'Specified ${buildFile.path} as input but the file '
        'does not exists.',
      );
    }
  }

  final pubspec = Pubspec.fromJson(mergedMap);

  final pubspecLockFile = File(
    normalize(join(basename(pubspecFile.parent.path), 'pubspec.lock')),
  );
  final pubspecLockContent = switch (pubspecLockFile.existsSync()) {
    true => pubspecLockFile.readAsStringSync(),
    false => '',
  };
  final pubspecLockMap = loadYaml(pubspecLockContent) as YamlMap?;
  if (safeCast<String>(pubspecLockMap?['sdks']?['dart']) case final sdk?) {
    sdkConstraint ??= VersionConstraint.parse(sdk);
  }

  final analysisOptionsFile = File(
    normalize(join(basename(pubspecFile.parent.path), 'analysis_options.yaml')),
  );
  final analysisOptionsContent = switch (analysisOptionsFile.existsSync()) {
    true => analysisOptionsFile.readAsStringSync(),
    false => '',
  };
  final analysisOptionsMap = loadYaml(analysisOptionsContent) as YamlMap?;
  // final formatterTrailingCommas = switch (safeCast<String>(
  //   analysisOptionsMap?['formatter']?['trailing_commas'],
  // )) {
  //   final s? => TrailingCommas.values.firstWhereOrNull((e) => e.name == s),
  //   _ => null,
  // };
  final formatterPageWidth = safeCast<int>(
    analysisOptionsMap?['formatter']?['page_width'],
  );

  return Config._(
    pubspec: pubspec,
    pubspecFile: pubspecFile,
    sdkConstraint: sdkConstraint,
    // formatterTrailingCommas: formatterTrailingCommas,
    formatterPageWidth: formatterPageWidth,
  );
}

Config? loadPubspecConfigOrNull(File pubspecFile, {File? buildFile}) {
  try {
    return loadPubspecConfig(pubspecFile, buildFile: buildFile);
  } on FileSystemException catch (e, s) {
    log.severe('File system error when reading files.', e, s);
  } on InvalidSettingsException catch (e, s) {
    log.severe('Invalid settings in files.', e, s);
  }
  return null;
}
