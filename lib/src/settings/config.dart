import 'dart:io';

import 'package:flutter_gen/src/settings/flutter/flutter.dart';
import 'package:flutter_gen/src/settings/flutterGen/flutter_gen.dart';
import 'package:flutter_gen/src/utils/cast.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Config {
  Config(this.pubspecFile);

  // ignore: non_constant_identifier_names
  static String DEFAULT_OUTPUT = 'lib${separator}gen$separator';

  final File pubspecFile;
  Flutter flutter;
  FlutterGen flutterGen;

  Future<Config> load() async {
    print(
        'FlutterGen Loading ... ${join(basename(pubspecFile.parent.path), basename(pubspecFile.path))}');
    final pubspec =
        await pubspecFile.readAsString().catchError((dynamic error) {
      throw FileSystemException(
          'Cannot open pubspec.yaml: ${pubspecFile.absolute}');
    });
    if (pubspec.isEmpty) {
      throw const FormatException('pubspec.yaml is empty');
    }

    final properties = safeCast<YamlMap>(loadYaml(pubspec));

    if (properties.containsKey('flutter')) {
      flutter = Flutter(safeCast<YamlMap>(properties['flutter']));
    }
    if (properties.containsKey('flutter_gen')) {
      flutterGen = FlutterGen(safeCast<YamlMap>(properties['flutter_gen']));
    }

    if (!hasFlutter && !hasFlutterGen) {
      throw const FormatException('FlutterGen settings not founded.');
    }

    return this;
  }

  bool get hasFlutterGen => flutterGen != null;

  bool get hasFlutter => flutter != null;
}
