import 'dart:io';

import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/utils/version.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../utils/map.dart';
import 'pubspec.dart';

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
  final defaultMap = loadYaml(_defaultConfig) as Map?;
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

const _defaultConfig = '''
name: $invalidStringValue

flutter_gen:
  output: lib/gen/
  line_length: 80

  integrations:
    flutter_svg: false
    flare_flutter: false
    rive: false

  assets:
    enabled: true
    outputs:
      class_name: Assets
      package_parameter_enabled: false
      style: dot-delimiter
    exclude: []
    
  fonts:
    enabled: true
    outputs:
      class_name: FontFamily

  colors:
    enabled: true
    inputs: []
    outputs:
      class_name: ColorName

flutter:
  assets: []
  fonts: []
''';
