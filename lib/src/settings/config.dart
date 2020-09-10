import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../utils/cast.dart';
import '../utils/error.dart';
import 'flutter.dart';
import 'flutter_gen.dart';

class Config {
  Config(this.pubspecFile);

  static final String defaultOutput = 'lib${separator}gen$separator';
  static const int defaultLineLength = 80;

  final File pubspecFile;
  Flutter flutter;
  FlutterGen flutterGen;

  Future<Config> load() async {
    print('FlutterGen Loading ... '
        '${normalize(join(
      basename(pubspecFile.parent.path),
      basename(pubspecFile.path),
    ))}');
    final pubspec =
        await pubspecFile.readAsString().catchError((dynamic error) {
      throw FileSystemException(
          'Cannot open pubspec.yaml: ${pubspecFile.absolute}');
    });
    if (pubspec.isEmpty) {
      throw const InvalidSettingsException('pubspec.yaml is empty');
    }

    final properties = safeCast<YamlMap>(loadYaml(pubspec));

    if (properties.containsKey('flutter')) {
      flutter = Flutter(safeCast<YamlMap>(properties['flutter']));
    }
    if (properties.containsKey('flutter_gen')) {
      flutterGen = FlutterGen(safeCast<YamlMap>(properties['flutter_gen']));
    }

    if (!hasFlutter && !hasFlutterGen) {
      throw const InvalidSettingsException('FlutterGen settings not founded.');
    }

    return this;
  }

  bool get hasFlutterGen => flutterGen != null;

  bool get hasFlutter => flutter != null;
}
