import 'dart:io';

import 'package:flutter_gen_core/settings/config_default.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:flutter_gen_core/utils/map.dart';
import 'package:flutter_gen_core/version.gen.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Config {
  const Config._({required this.pubspec, required this.pubspecFile});

  final Pubspec pubspec;
  final File pubspecFile;
}

Config loadPubspecConfig(File pubspecFile, {File? buildFile}) {
  final pubspecLocaleHint = normalize(
    join(basename(pubspecFile.parent.path), basename(pubspecFile.path)),
  );

  log.info('[FlutterGen] v$packageVersion Loading ...');
  log.info('[FlutterGen] Reading options from $pubspecLocaleHint');

  final defaultMap = loadYaml(configDefaultYamlContent) as Map?;

  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspecMap = loadYaml(pubspecContent) as Map?;
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
        log.info('[FlutterGen] Reading options from $buildLocaleHint');
      } else {
        log.severe(
          '[FlutterGen] Specified ${buildFile.path} as input but the file '
          'does not contain valid options, ignoring...',
        );
      }
    } else {
      log.warning(
        '[FlutterGen] Specified ${buildFile.path} as input but the file '
        'does not exists.',
      );
    }
  }

  final pubspec = Pubspec.fromJson(mergedMap);
  return Config._(pubspec: pubspec, pubspecFile: pubspecFile);
}

Config? loadPubspecConfigOrNull(File pubspecFile, {File? buildFile}) {
  try {
    return loadPubspecConfig(pubspecFile, buildFile: buildFile);
  } on FileSystemException catch (e, s) {
    log.severe('[FlutterGen] File system error when reading files.', e, s);
  } on InvalidSettingsException catch (e, s) {
    log.severe('[FlutterGen] Invalid settings in files.', e, s);
  }
  return null;
}
