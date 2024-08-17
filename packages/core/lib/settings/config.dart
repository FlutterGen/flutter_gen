import 'dart:io';

import 'package:flutter_gen_core/settings/config_default.dart';
import 'package:flutter_gen_core/settings/pubspec.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/map.dart';
import 'package:flutter_gen_core/utils/version.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config._({required this.pubspec, required this.pubspecFile});

  final Pubspec pubspec;
  final File pubspecFile;
}

Config loadPubspecConfig(File pubspecFile, {File? buildFile}) {
  final pubspecLocaleHint = normalize(
    join(basename(pubspecFile.parent.path), basename(pubspecFile.path)),
  );
  final buildLocaleHint = buildFile != null && buildFile.existsSync()
      ? ', ${normalize(
          join(basename(buildFile.parent.path), basename(buildFile.path)),
        )} '
      : '';

  stdout.writeln(
    '$flutterGenVersion Loading ... $pubspecLocaleHint$buildLocaleHint',
  );

  final defaultMap = loadYaml(configDefaultYamlContent) as Map?;

  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspecMap = loadYaml(pubspecContent) as Map?;

  var mergedMap = mergeMap([defaultMap, pubspecMap]);

  if (buildFile != null && buildFile.existsSync()) {
    final buildContent = buildFile.readAsStringSync();
    final rawMap = loadYaml(buildContent) as Map?;
    final optionBuildMap = rawMap?['targets']?[r'$default']?['builders']
        ?['flutter_gen']?['options'];

    if (optionBuildMap != null) {
      final buildMap = {'flutter_gen': optionBuildMap};
      mergedMap = mergeMap([mergedMap, buildMap]);
    }
  }

  final pubspec = Pubspec.fromJson(mergedMap);
  return Config._(pubspec: pubspec, pubspecFile: pubspecFile);
}

Config? loadPubspecConfigOrNull(File pubspecFile, {File? buildFile}) {
  try {
    return loadPubspecConfig(pubspecFile, buildFile: buildFile);
  } on FileSystemException catch (e) {
    stderr.writeln(e.message);
  } on InvalidSettingsException catch (e) {
    stderr.writeln(e.message);
  }
  return null;
}
