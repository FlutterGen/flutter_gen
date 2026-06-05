// Verify flutter_gen_core works against every supported major `xml` version.
//
// The package declares `xml: '>=6.0.0 <8.0.0'`, but `dart pub get` is
// conservative and resolves to the 6.x line by default (because the package
// still supports older SDKs, while xml 7.x requires Dart >= 3.11). As a result
// the normal `melos test` only ever exercises one of the two majors.
//
// This script pins each major in turn via a temporary `pubspec_overrides.yaml`
// (gitignored) and runs the core test suite against it, so a regression on
// either xml 6.x or 7.x is caught.
//
// It is pure Dart (only `dart:io`) so it runs identically on Linux, macOS and
// Windows. The xml 7.x pass requires Dart >= 3.11; on older toolchains it is
// skipped with a warning instead of failing.
//
// Run via `melos test:xml-matrix` or `dart scripts/test_xml_versions.dart`.

import 'dart:io';

Future<void> main() async {
  final coreDir = Directory('${_repoRoot().path}/packages/core');
  final override = File('${coreDir.path}/pubspec_overrides.yaml');

  // Always remove the temporary override and re-resolve so the working tree
  // and lockfile are left in their default state, even if a pass fails.
  void cleanup() {
    if (override.existsSync()) override.deleteSync();
    Process.runSync(
      Platform.resolvedExecutable,
      ['pub', 'get'],
      workingDirectory: coreDir.path,
    );
  }

  try {
    await _runPass('^6.0.0', coreDir, override);

    final dart = _dartVersion();
    if (dart.major > 3 || (dart.major == 3 && dart.minor >= 11)) {
      await _runPass('^7.0.0', coreDir, override);
    } else {
      stdout.writeln('\n⚠️  Skipping xml 7.x pass: requires Dart >= 3.11 '
          '(found ${dart.major}.${dart.minor}).');
    }
  } catch (error) {
    cleanup();
    stderr.writeln('\n❌ $error');
    exit(1);
  }

  cleanup();
  stdout
      .writeln('\n✅ flutter_gen_core passed against all checked xml versions.');
}

Future<void> _runPass(
  String constraint,
  Directory coreDir,
  File override,
) async {
  stdout.writeln('\n========================================================');
  stdout.writeln(' flutter_gen_core test pass — pinning xml: $constraint');
  stdout.writeln('========================================================');
  override.writeAsStringSync('dependency_overrides:\n  xml: $constraint\n');
  await _dart(['pub', 'get'], coreDir);
  stdout.writeln('-> resolved xml ${_resolvedXmlVersion(coreDir)}');
  await _dart(['test'], coreDir);
}

/// Runs `dart <args>` in [cwd], streaming output, and throws on failure.
Future<void> _dart(List<String> args, Directory cwd) async {
  final process = await Process.start(
    Platform.resolvedExecutable,
    args,
    workingDirectory: cwd.path,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw 'dart ${args.join(' ')} failed (exit $code) in ${cwd.path}';
  }
}

/// Parses the running Dart SDK version, e.g. "3.11.3 (stable) (...)".
({int major, int minor}) _dartVersion() {
  final parts = Platform.version.split(' ').first.split('.');
  return (major: int.parse(parts[0]), minor: int.parse(parts[1]));
}

/// Reads the resolved `xml` version out of `packages/core/pubspec.lock`.
String _resolvedXmlVersion(Directory coreDir) {
  final lock = File('${coreDir.path}/pubspec.lock');
  if (!lock.existsSync()) return 'unknown';
  final lines = lock.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].trimRight() == '  xml:') {
      for (var j = i + 1;
          j < lines.length && lines[j].startsWith('    ');
          j++) {
        final match = RegExp(r'version:\s*"?([^"\s]+)"?').firstMatch(lines[j]);
        if (match != null) return match.group(1)!;
      }
    }
  }
  return 'unknown';
}

/// Locates the melos workspace root by walking up from this script's location,
/// falling back to the current directory (melos runs scripts from the root).
Directory _repoRoot() {
  var dir = File.fromUri(Platform.script).parent;
  while (dir.path != dir.parent.path) {
    if (File('${dir.path}/melos.yaml').existsSync()) return dir;
    dir = dir.parent;
  }
  return Directory.current;
}
