import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../utils/map.dart';
import 'pubspec.dart';

class Config {
  Config._({required this.pubspec});

  final Pubspec pubspec;

  @Deprecated('Access from pubspec')
  FlutterGen get flutterGen => pubspec.flutterGen;

  @Deprecated('Access from pubspec')
  Flutter get flutter => pubspec.flutter;
}

Future<Config> loadPubspecConfig(File pubspecFile) async {
  print('FlutterGen Loading ... '
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
  # deprecated key
  lineLength: -1
  line_length: 80
  null_safety: true

  integrations:
    flutter_svg: false
    flare_flutter: false

  assets:
    enabled: true
    package_parameter_enabled: false
    style: dot-delimiter
    
  fonts:
    enabled: true

  colors:
    enabled: true
    inputs: []

flutter:
  assets: []
  fonts: []
''';
