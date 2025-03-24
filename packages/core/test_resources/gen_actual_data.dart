import 'dart:io';

import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart';

void main(List<String> args) async {
  // Make sure the working directory is the same as the script.
  final scriptUri = Platform.script;
  final scriptFile = File.fromUri(scriptUri);
  final absolutePath = scriptFile.absolute.path;
  Directory.current = dirname(absolutePath);

  // Remove old generated files.
  final libDir = Directory('lib');

  if (await libDir.exists()) {
    await libDir.delete(recursive: true);
  }

  // Generate all files.
  await _generateWithPubspecFiles('assets');
  await _generateWithPubspecFiles('colors');
  await _generateWithPubspecFiles('fonts');
  await _generateWithBuildFiles();

  // Copy all generated files to the actual data directory.
  for (final entry in Glob('${libDir.path}/**.dart').listSync()) {
    final file = File(entry.path);
    final targetPath = join('actual_data', basename(entry.path));
    await file.copy(targetPath);
  }

  // Clear the working directory.
  if (await libDir.exists()) {
    await libDir.delete(recursive: true);
  }
}

Future<void> _generateWithPubspecFiles(String kind) async {
  final prefix = 'pubspec_${kind}';
  final ext = '.yaml';
  final pubspecs = Glob('$prefix*$ext');

  for (final entry in pubspecs.listSync()) {
    try {
      final file = File(entry.path);
      final name = entry.basename
          .replaceAll(RegExp('^$prefix[_]?'), '')
          .replaceAll(RegExp('\\$ext\$'), '');
      final targetName =
          name.isEmpty ? '$kind.gen.dart' : '${kind}_$name.gen.dart';

      await FlutterGenerator(
        file,
        assetsName: targetName,
        fontsName: targetName,
        colorsName: targetName,
      ).build();
    } catch (e) {
      stderr.write(e);
    }
  }
}

Future<void> _generateWithBuildFiles() async {
  final prefix = 'build_';
  final ext = '.yaml';
  final buildFiles = Glob('$prefix*$ext');

  for (final entry in buildFiles.listSync()) {
    try {
      final file = File(entry.path);
      final name = entry.basename
          .replaceAll(RegExp('^$prefix'), '')
          .replaceAll(RegExp('\\$ext\$'), '');
      final targetName = '$prefix$name.gen.dart';

      await FlutterGenerator(
        File('pubspec_assets.yaml'),
        buildFile: file,
        assetsName: targetName,
        fontsName: targetName,
        colorsName: targetName,
      ).build();
    } catch (e) {
      stderr.write(e);
    }
  }
}
