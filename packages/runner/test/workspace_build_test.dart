import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('supports build_runner --workspace and cleans stale outputs', () async {
    final workspaceDir = await _createWorkspaceFixture();
    addTearDown(() async {
      if (workspaceDir.existsSync()) {
        workspaceDir.deleteSync(recursive: true);
      }
    });

    await _runProcess(
      'flutter',
      ['pub', 'get'],
      workingDirectory: workspaceDir.path,
    );

    await _runProcess(
      'dart',
      [
        'run',
        'build_runner',
        'build',
        '--workspace',
        '--delete-conflicting-outputs',
      ],
      workingDirectory: workspaceDir.path,
    );

    final appDir = Directory(p.join(workspaceDir.path, 'packages', 'app'));
    final ownerFile = File(
      p.join(
        appDir.path,
        '.dart_tool',
        'flutter_build',
        'flutter_gen',
        'flutter_gen_owner.json',
      ),
    );

    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'assets.gen.dart')).existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'colors.gen.dart')).existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'fonts.gen.dart')).existsSync(),
      isTrue,
    );
    expect(ownerFile.existsSync(), isTrue);

    final initialOwner =
        jsonDecode(ownerFile.readAsStringSync()) as Map<String, Object?>;
    expect(
      initialOwner['paths'],
      containsAll([
        'lib/gen/assets.gen.dart',
        'lib/gen/colors.gen.dart',
        'lib/gen/fonts.gen.dart',
      ]),
    );

    final appPubspec = File(p.join(appDir.path, 'pubspec.yaml'));
    appPubspec.writeAsStringSync(
      appPubspec
          .readAsStringSync()
          .replaceFirst('output: lib/gen/', 'output: lib/alt_gen/'),
    );

    await _runProcess(
      'dart',
      [
        'run',
        'build_runner',
        'build',
        '--workspace',
        '--delete-conflicting-outputs',
      ],
      workingDirectory: workspaceDir.path,
    );

    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'assets.gen.dart')).existsSync(),
      isFalse,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'colors.gen.dart')).existsSync(),
      isFalse,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'fonts.gen.dart')).existsSync(),
      isFalse,
    );

    expect(
      File(p.join(appDir.path, 'lib', 'alt_gen', 'assets.gen.dart'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'alt_gen', 'colors.gen.dart'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'alt_gen', 'fonts.gen.dart'))
          .existsSync(),
      isTrue,
    );

    final updatedOwner =
        jsonDecode(ownerFile.readAsStringSync()) as Map<String, Object?>;
    expect(
      updatedOwner['paths'],
      containsAll([
        'lib/alt_gen/assets.gen.dart',
        'lib/alt_gen/colors.gen.dart',
        'lib/alt_gen/fonts.gen.dart',
      ]),
    );
  });

  test('applies package build.yaml options in workspace mode', () async {
    final workspaceDir = await _createWorkspaceFixture();
    addTearDown(() async {
      if (workspaceDir.existsSync()) {
        workspaceDir.deleteSync(recursive: true);
      }
    });

    final appDir = Directory(p.join(workspaceDir.path, 'packages', 'app'));
    final appBuildYaml = File(p.join(appDir.path, 'build.yaml'));
    appBuildYaml.writeAsStringSync(r'''
targets:
  $default:
    builders:
      flutter_gen_runner:
        options:
          output: lib/build_gen/
''');

    await _runProcess(
      'flutter',
      ['pub', 'get'],
      workingDirectory: workspaceDir.path,
    );

    await _runProcess(
      'dart',
      [
        'run',
        'build_runner',
        'build',
        '--workspace',
        '--delete-conflicting-outputs',
      ],
      workingDirectory: workspaceDir.path,
    );

    expect(
      File(p.join(appDir.path, 'lib', 'build_gen', 'assets.gen.dart'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'build_gen', 'colors.gen.dart'))
          .existsSync(),
      isTrue,
    );
    expect(
      File(p.join(appDir.path, 'lib', 'build_gen', 'fonts.gen.dart'))
          .existsSync(),
      isTrue,
    );

    expect(
      File(p.join(appDir.path, 'lib', 'gen', 'assets.gen.dart')).existsSync(),
      isFalse,
    );
  });
}

Future<Directory> _createWorkspaceFixture() async {
  final runnerDir = _runnerPackageDirectory();
  final fixtureDir =
      Directory(p.join(runnerDir.path, 'test_fixtures', 'workspace'));
  final tempDir =
      await Directory.systemTemp.createTemp('flutter_gen_workspace_fixture_');

  await _copyDirectory(fixtureDir, tempDir);

  final appPubspecTemplate = File(
    p.join(tempDir.path, 'packages', 'app', 'pubspec.yaml.template'),
  );
  final appPubspec = File(
    p.join(tempDir.path, 'packages', 'app', 'pubspec.yaml'),
  );
  final coreDir = Directory(p.join(runnerDir.parent.path, 'core'));
  appPubspec.writeAsStringSync(
    appPubspecTemplate
        .readAsStringSync()
        .replaceAll('__RUNNER_PATH__', _yamlPath(runnerDir.path))
        .replaceAll('__CORE_PATH__', _yamlPath(coreDir.path)),
  );
  appPubspecTemplate.deleteSync();

  return tempDir;
}

Directory _runnerPackageDirectory() {
  return Directory.current;
}

String _yamlPath(String path) {
  return p.normalize(path).replaceAll(r'\', '/');
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

Future<void> _runProcess(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) async {
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: true,
  );

  if (result.exitCode != 0) {
    fail(
      'Command failed: $executable ${arguments.join(' ')}\n'
      'exitCode: ${result.exitCode}\n'
      'stdout:\n${result.stdout}\n'
      'stderr:\n${result.stderr}',
    );
  }
}
