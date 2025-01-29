import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/utils/cast.dart';
import 'package:flutter_gen_core/utils/error.dart';
import 'package:flutter_gen_core/version.gen.dart';

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption(
    'config',
    abbr: 'c',
    help: 'Set the path of pubspec.yaml.',
    defaultsTo: 'pubspec.yaml',
  );

  parser.addOption(
    'build',
    abbr: 'b',
    help: 'Set the path of build.yaml.',
  );

  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Help about any command',
    defaultsTo: false,
  );

  parser.addFlag(
    'version',
    abbr: 'v',
    help: 'FlutterGen version',
    defaultsTo: false,
  );

  ArgResults results;
  try {
    results = parser.parse(args);
    if (results.wasParsed('help')) {
      stdout.writeln(parser.usage);
      return;
    } else if (results.wasParsed('version')) {
      stdout.writeln('[FlutterGen] v$packageVersion');
      return;
    }
  } on FormatException catch (e) {
    stderr.writeAll(
      <String>[e.message, 'usage: flutter_gen [options...]', ''],
      '\n',
    );
    return;
  }

  final pubspecPath = safeCast<String>(results['config']);
  if (pubspecPath == null || pubspecPath.trim().isEmpty) {
    throw ArgumentError('Invalid value $pubspecPath', 'config');
  }
  final pubspecFile = File(pubspecPath).absolute;

  final buildPath = safeCast<String>(results['build'])?.trim();
  if (buildPath?.isEmpty ?? false) {
    throw ArgumentError('Invalid value $buildPath', 'build');
  }
  final buildFile = buildPath == null ? null : File(buildPath).absolute;

  try {
    await FlutterGenerator(pubspecFile, buildFile: buildFile).build();
  } on InvalidSettingsException catch (e) {
    stderr.write(e.message);
  }
}
