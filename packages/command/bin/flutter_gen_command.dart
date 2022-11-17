import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/utils/cast.dart';
import 'package:flutter_gen_core/utils/version.dart';

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption(
    'config',
    abbr: 'c',
    help: 'Set the path of pubspec.yaml.',
    defaultsTo: 'pubspec.yaml',
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
      stdout.writeln(flutterGenVersion);
      return;
    }
  } on FormatException catch (e) {
    stderr.writeAll(
        <String>[e.message, 'usage: flutter_gen [options...]', ''], '\n');
    return;
  }

  final pubspecPath = safeCast<String>(results['config']);
  FlutterGenerator(File(pubspecPath!).absolute).build();
}
