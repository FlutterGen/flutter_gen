import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../utils/map.dart';
import 'pubspec.dart';

class Config {
  Config._({required this.pubspec});

  final Pubspec pubspec;
}

Future<Config> loadPubspecConfig(File pubspecFile) async {
  stdout.writeln('FlutterGen Loading ... '
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
  return Config._(pubspec: pubspec);
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
    
  fonts:
    enabled: true

  colors:
    enabled: true
    inputs: []

  exclude: []

flutter:
  assets: []
  fonts: []
''';
