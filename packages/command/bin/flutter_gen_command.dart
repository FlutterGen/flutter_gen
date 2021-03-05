import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/utils/cast.dart';

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption(
    'config',
    abbr: 'c',
    defaultsTo: 'pubspec.yaml',
    help: 'Set the path of pubspec.yaml.',
  );

  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Help about any command',
    defaultsTo: false,
  );

  /// TODO: Until null safety generalizes
  parser.addFlag(
    'no-sound-null-safety',
    help: 'Disable sound null safety',
    defaultsTo: false,
  );

  ArgResults results;
  var disabledNullSafety = false;
  try {
    results = parser.parse(args);
    if (results.wasParsed('help')) {
      print(parser.usage);
      return;
    }

    // TODO: Until null safety generalizes
    if (results.wasParsed('no-sound-null-safety')) {
      disabledNullSafety = true;
    }
  } on FormatException catch (e) {
    stderr.writeAll(
        <String>[e.message, 'usage: flutter_gen [options...] ', ''], '\n');
    return;
  }

  final pubspecPath = safeCast<String>(results['config']);
  FlutterGenerator(
    File(pubspecPath!).absolute,
    disabledNullSafety: disabledNullSafety,
  ).build();
}
