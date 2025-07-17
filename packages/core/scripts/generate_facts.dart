import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:path/path.dart' as p;

late final Directory dir;

void main() async {
  dir = File.fromUri(Platform.script).parent.parent.directory('test_resources');
  final configFiles = dir.listSync().whereType<File>().where(
        (e) => e.extension == '.yaml',
      );
  for (final file in configFiles) {
    final File pubspecFile;
    final File? buildFile;
    final String namePrefix;
    if (file.name.startsWith('build_')) {
      pubspecFile = File(p.join(dir.path, 'pubspec_assets.yaml'));
      buildFile = file;
      namePrefix = 'build_';
    } else {
      pubspecFile = file;
      buildFile = null;
      namePrefix = '';
    }
    final name = file.nameWithoutExtension.removePrefix('pubspec_');
    final generator = FlutterGenerator(
      pubspecFile,
      buildFile: buildFile,
      assetsName: '${namePrefix}assets_$name.gen.dart',
      colorsName: '${namePrefix}colors_$name.gen.dart',
      fontsName: '${namePrefix}fonts_$name.gen.dart',
      overrideOutputPath: p.join(dir.path, 'actual_data'),
    );
    await generator.build().catchError((e, s) {
      stderr.writeln('[FAILED] ${file.name} - ${buildFile?.name ?? 'N/A'}');
      stderr.writeln('$e');
      stderr.writeln('$s');
    });
  }
}
