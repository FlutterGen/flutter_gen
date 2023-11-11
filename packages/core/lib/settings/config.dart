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

Config loadPubspecConfig(File pubspecFile) {
  stdout.writeln('$flutterGenVersion Loading ... '
      '${normalize(join(
    basename(pubspecFile.parent.path),
    basename(pubspecFile.path),
  ))}');
  final content = pubspecFile.readAsStringSync();
  final userMap = loadYaml(content) as Map?;
  final defaultMap = loadYaml(configDefaultYamlContent) as Map?;
  final mergedMap = mergeMap([defaultMap, userMap]);
  final pubspec = Pubspec.fromJson(mergedMap);
  return Config._(pubspec: pubspec, pubspecFile: pubspecFile);
}

Config? loadPubspecConfigOrNull(File pubspecFile) {
  try {
    return loadPubspecConfig(pubspecFile);
  } on FileSystemException catch (e) {
    stderr.writeln(e.message);
  } on InvalidSettingsException catch (e) {
    stderr.writeln(e.message);
  }
  return null;
}
