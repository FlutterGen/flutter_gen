import 'dart:io';

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

Future<Config> loadPubspecConfig(File pubspecFile) async {
  stdout.writeln('$flutterGenVersion Loading ... '
      '${normalize(join(
    basename(pubspecFile.parent.path),
    basename(pubspecFile.path),
  ))}');
  final content = await pubspecFile.readAsString().catchError((dynamic error) {
    throw FileSystemException(
        'Cannot open pubspec.yaml: ${pubspecFile.absolute}');
  });
  final userMap = loadYaml(content) as Map?;
  final defaultMap = loadYaml(_defaultConfig) as Map?;
  final mergedMap = mergeMap([defaultMap, userMap]);
  final pubspec = Pubspec.fromJson(mergedMap);
  return Config._(pubspec: pubspec, pubspecFile: pubspecFile);
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
    package_parameter_enabled: false
    style: dot-delimiter
    exclude: []
    
  fonts:
    enabled: true

  colors:
    enabled: true
    inputs: []

flutter:
  assets: []
  fonts: []
''';
