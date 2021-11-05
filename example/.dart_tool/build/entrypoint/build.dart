// ignore_for_file: directives_ordering
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:flutter_gen_runner/flutter_gen_runner.dart' as _i2;
import 'package:freezed/builder.dart' as _i3;
import 'package:json_serializable/builder.dart' as _i4;
import 'package:source_gen/builder.dart' as _i5;
import 'dart:isolate' as _i6;
import 'package:build_runner/build_runner.dart' as _i7;
import 'dart:io' as _i8;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(r'flutter_gen_runner:flutter_gen_runner', [_i2.build],
      _i1.toDependentsOf(r'flutter_gen_runner'),
      hideOutput: false),
  _i1.apply(r'freezed:freezed', [_i3.freezed], _i1.toDependentsOf(r'freezed'),
      hideOutput: false),
  _i1.apply(r'json_serializable:json_serializable', [_i4.jsonSerializable],
      _i1.toDependentsOf(r'json_serializable'),
      hideOutput: true,
      appliesBuilders: const [r'source_gen:combining_builder']),
  _i1.apply(r'source_gen:combining_builder', [_i5.combiningBuilder],
      _i1.toNoneByDefault(),
      hideOutput: false, appliesBuilders: const [r'source_gen:part_cleanup']),
  _i1.applyPostProcess(r'source_gen:part_cleanup', _i5.partCleanup)
];
void main(List<String> args, [_i6.SendPort? sendPort]) async {
  var result = await _i7.run(args, _builders);
  sendPort?.send(result);
  _i8.exitCode = result;
}
