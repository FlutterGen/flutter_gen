import 'dart:io' show Platform;

import 'package:flutter_gen_core/generators/generator_helper.dart' as helper;
import 'package:flutter_gen_core/version.gen.dart';
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
      equals('-c, --config          Set the path of pubspec.yaml.'),
    );
    final line = await process.stdout.next;
    expect(line.trim(), equals('(defaults to "pubspec.yaml")'));
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
}
