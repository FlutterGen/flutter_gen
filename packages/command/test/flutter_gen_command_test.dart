import 'dart:io';

import 'package:flutter_gen_core/version.gen.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

final separator = Platform.pathSeparator;

void main() {
  test('Execute fluttergen', () async {
    final process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart'],
    );
    expect(
      await process.stdout.next,
      equals('[FlutterGen] v$packageVersion Loading ...'),
    );
    await process.shouldExit(0);
  });

  test('Execute fluttergen --config pubspec.yaml', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--config', 'pubspec.yaml'],
    );
    expect(
      await process.stdout.next,
      equals('[FlutterGen] v$packageVersion Loading ...'),
    );
    await process.shouldExit(0);
  });

  test('Execute fluttergen --help', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--help'],
    );
    expect(
      await process.stdout.next,
      equals('[FlutterGen] Usage of the `fluttergen` command:'),
    );
    expect(await process.stdout.next, contains('--config'));
    final line = await process.stdout.next;
    expect(line.trim(), equals('(defaults to "pubspec.yaml")'));
    expect(await process.stdout.next, contains('--build'));
    expect(await process.stdout.next, contains('workspace'));
    await process.shouldExit(0);
  });

  test('Execute fluttergen --version', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--version'],
    );
    expect(await process.stdout.next, equals('[FlutterGen] v$packageVersion'));
    await process.shouldExit(0);
  });

  test('Execute wrong arguments with fluttergen --wrong', () async {
    var process = await TestProcess.start(
      'dart',
      ['bin/flutter_gen_command.dart', '--wrong'],
    );
    expect(
      await process.stderr.next,
      equals('Unhandled exception:'),
    );
    expect(
      await process.stderr.next,
      equals('FormatException: Could not find an option named "--wrong".'),
    );
    await process.shouldExit(255);
  });

  test('Execute deprecated config with fluttergen', () async {
    final process = await TestProcess.start(
      'dart',
      [
        'bin/flutter_gen_command.dart',
        '--config',
        'test/deprecated_configs.yaml',
      ],
    );
    expect(
      await process.stderr.next,
      equals('Unhandled exception:'),
    );
    expect(
      await process.stderr.next,
      startsWith('InvalidSettingsException: '),
    );
    final rest = (await process.stderr.rest.toList()).join('\n');
    expect(rest, contains('style'));
    expect(rest, contains('package_parameter_enabled'));
    await process.shouldExit(255);
  });

  test('Execute fluttergen --workspace', () async {
    final workspaceDir = await _copyExampleWorkspace();
    addTearDown(() async {
      if (workspaceDir.existsSync()) {
        workspaceDir.deleteSync(recursive: true);
      }
    });

    await _deleteGeneratedDirs(workspaceDir);

    final process = await TestProcess.start(
      'dart',
      [
        'run',
        p.join(Directory.current.path, 'bin', 'flutter_gen_command.dart'),
        '--workspace',
        '--config',
        p.join(workspaceDir.path, 'pubspec.yaml'),
      ],
      workingDirectory: workspaceDir.path,
    );

    await process.shouldExit(0);

    expect(
      File(
        p.join(
          workspaceDir.path,
          'packages',
          'gallery_one',
          'lib',
          'gen',
          'assets.gen.dart',
        ),
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        p.join(
          workspaceDir.path,
          'packages',
          'gallery_two',
          'lib',
          'gen',
          'assets.gen.dart',
        ),
      ).existsSync(),
      isTrue,
    );
  });

  test('Execute fluttergen uses package-local build.yaml for config file',
      () async {
    final workspaceDir = await _copyExampleWorkspace();
    addTearDown(() async {
      if (workspaceDir.existsSync()) {
        workspaceDir.deleteSync(recursive: true);
      }
    });

    final galleryOneDir = Directory(
      p.join(workspaceDir.path, 'packages', 'gallery_one'),
    );
    await _deleteGeneratedDirs(workspaceDir);

    File(p.join(galleryOneDir.path, 'build.yaml')).writeAsStringSync(r'''
targets:
  $default:
    builders:
      flutter_gen_runner:
        options:
          output: lib/build_gen/
''');

    final process = await TestProcess.start(
      'dart',
      [
        'run',
        p.join(Directory.current.path, 'bin', 'flutter_gen_command.dart'),
        '--config',
        p.join(galleryOneDir.path, 'pubspec.yaml'),
      ],
      workingDirectory: workspaceDir.path,
    );

    await process.shouldExit(0);

    expect(
      File(p.join(galleryOneDir.path, 'lib', 'build_gen', 'assets.gen.dart'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(galleryOneDir.path, 'lib', 'gen', 'assets.gen.dart'))
          .existsSync(),
      isFalse,
    );
  });
}

Future<Directory> _copyExampleWorkspace() async {
  final source = Directory(
    p.normalize(
      p.join(
        Directory.current.path,
        '..',
        '..',
        'examples',
        'example_workspace',
      ),
    ),
  );
  final destination = await Directory.systemTemp.createTemp(
    'fluttergen_command_workspace_',
  );
  await _copyDirectory(source, destination);
  return destination;
}

Future<void> _deleteGeneratedDirs(Directory workspaceDir) async {
  for (final relativePath in [
    p.join('packages', 'gallery_one', 'lib', 'gen'),
    p.join('packages', 'gallery_one', 'lib', 'build_gen'),
    p.join('packages', 'gallery_two', 'lib', 'gen'),
    p.join('packages', 'gallery_two', 'lib', 'build_gen'),
  ]) {
    final directory = Directory(p.join(workspaceDir.path, relativePath));
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await for (final entity in source.list(recursive: true, followLinks: false)) {
    final relativePath = p.relative(entity.path, from: source.path);
    final targetPath = p.join(destination.path, relativePath);
    if (entity is Directory) {
      Directory(targetPath).createSync(recursive: true);
    } else if (entity is File) {
      File(targetPath).parent.createSync(recursive: true);
      entity.copySync(targetPath);
    }
  }
}
