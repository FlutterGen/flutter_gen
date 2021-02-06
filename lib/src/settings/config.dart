import 'dart:io';

import 'package:merge_map/merge_map.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'pubspec.dart';

class Config {
  Config._({this.pubSpec});

  final PubSpec pubSpec;

  FlutterGen get flutterGen => pubSpec.flutterGen;

  Flutter get flutter => pubSpec.flutter;
}

Future<Config> loadPubspecConfig(File pubSpecFile) async {
  print('FlutterGen Loading ... '
      '${normalize(join(
    basename(pubSpecFile.parent.path),
    basename(pubSpecFile.path),
  ))}');
  final content = await pubSpecFile.readAsString().catchError((dynamic error) {
    throw FileSystemException(
        'Cannot open pubspec.yaml: ${pubSpecFile.absolute}');
  });
  final userMap = loadYaml(content) as Map;
  final defaultMap = loadYaml(_defaultConfig) as Map;
  final mergedMap = mergeMap([defaultMap, userMap]);
  final pubSpec = PubSpec.fromJson(mergedMap);
  return Config._(pubSpec: pubSpec);
}

const _defaultConfig = '''
flutter_gen:
  output: lib/gen/
  lineLength: 80
  line_length: 80

  integrations:
    flutter_svg: false
    flare_flutter: false

  assets:
    style: dot-delimiter

  colors:
    inputs: []

flutter:
  assets: []
  fonts: []
''';
