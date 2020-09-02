import 'dart:io';

import 'package:flutter_gen/src/settings/flutter/flutter.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config(this.pubspecFile);

  static const String DEFAULT_OUTPUT = 'lib/gen';

  final File pubspecFile;
  Flutter flutter;
  FlutterGen flutterGen;

  Future<Config> load() async {
    final pubspec =
        await pubspecFile.readAsString().catchError((dynamic error) {
      print('Cannot open pubspec.yaml: ${pubspecFile.absolute}');
      exit(-1);
    });
    if (pubspec.isEmpty) {
      print('pubspec.yaml is empty');
      exit(-1);
    }

    final properties = loadYaml(pubspec) as YamlMap;

    if (properties.containsKey('flutter')) {
      flutter = Flutter(properties['flutter'] as YamlMap);
    }
    if (properties.containsKey('flutter_gen')) {
      flutterGen = FlutterGen(properties['flutter_gen'] as YamlMap);
    }

    return this;
  }

  bool get hasFlutterGen => flutterGen != null;

  bool get hasFlutter => flutter != null;
}
