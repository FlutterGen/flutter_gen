import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/utils/cast.dart' show safeCast;
import 'package:flutter_gen_core/utils/log.dart' show log;
import 'package:flutter_gen_core/version.gen.dart' show packageVersion;
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart' show Level;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

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
    'workspace',
    abbr: 'w',
    help: 'Generate for every workspace member listed in the config pubspec.',
    defaultsTo: false,
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

  final workspace = results['workspace'] as bool;
  if (workspace && buildFile != null) {
    throw ArgumentError(
      'The --build option is not supported together with --workspace. '
          'Use package-local build.yaml files inside each workspace member instead.',
      'build',
    );
  }

  if (workspace) {
    await _runWorkspace(pubspecFile);
    return;
  }

  await _runSinglePackage(pubspecFile, buildFile: buildFile);
}

Future<void> _runWorkspace(File workspacePubspecFile) async {
  final workspacePubspecMap =
      loadYaml(await workspacePubspecFile.readAsString()) as YamlMap?;
  final entries = (workspacePubspecMap?['workspace'] as YamlList?)
          ?.whereType<String>()
          .toList() ??
      const <String>[];

  if (entries.isEmpty) {
    throw ArgumentError(
      'No workspace members were found in ${workspacePubspecFile.path}.',
      'config',
    );
  }

  final workspaceRoot = workspacePubspecFile.parent;
  final packagePubspecs = <File>{};
  for (final entry in entries) {
    final glob = Glob(entry);
    for (final entity in glob.listSync(root: workspaceRoot.path)) {
      if (entity is! Directory) {
        continue;
      }
      final pubspecFile = File(p.join(entity.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        packagePubspecs.add(pubspecFile.absolute);
      }
    }
  }

  if (packagePubspecs.isEmpty) {
    throw ArgumentError(
      'No workspace member pubspec.yaml files were found from '
          '${workspacePubspecFile.path}.',
      'config',
    );
  }

  final orderedPubspecs = packagePubspecs.toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final packagePubspec in orderedPubspecs) {
    await _runSinglePackage(packagePubspec);
  }
}

Future<void> _runSinglePackage(
  File pubspecFile, {
  File? buildFile,
}) async {
  await FlutterGenerator(
    pubspecFile,
    buildFile: buildFile ?? _packageLocalBuildFile(pubspecFile),
  ).build();
}

File? _packageLocalBuildFile(File pubspecFile) {
  final buildFile = File(p.join(pubspecFile.parent.path, 'build.yaml'));
  return buildFile.existsSync() ? buildFile : null;
}
