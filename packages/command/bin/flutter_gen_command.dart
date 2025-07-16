import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/utils/cast.dart' show safeCast;
import 'package:flutter_gen_core/utils/log.dart' show log;
import 'package:flutter_gen_core/version.gen.dart' show packageVersion;
import 'package:logging/logging.dart' show Level;

void main(List<String> args) async {
  log.onRecord.listen((record) {
    if (record.level >= Level.WARNING) {
      stderr.writeln('[FlutterGen] [${record.level.name}] ${record.message}');
    } else {
      stdout.writeln('[FlutterGen] ${record.message}');
    }
  });

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
      log.info('Usage of the `fluttergen` command:\n${parser.usage}');
      return;
    } else if (results.wasParsed('version')) {
      log.info('v$packageVersion');
      return;
    }
  } on FormatException catch (e) {
    throw '$e\n\n${parser.usage}';
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

  await FlutterGenerator(pubspecFile, buildFile: buildFile).build();
}
