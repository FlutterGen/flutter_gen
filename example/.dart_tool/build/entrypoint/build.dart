// ignore_for_file: directives_ordering
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:flutter_gen_runner/flutter_gen_runner.dart' as _i2;
import 'dart:isolate' as _i3;
import 'package:build_runner/build_runner.dart' as _i4;
import 'dart:io' as _i5;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(r'flutter_gen_runner:flutter_gen_runner', [_i2.build],
      _i1.toDependentsOf(r'flutter_gen_runner'),
      hideOutput: false)
];
void main(List<String> args, [_i3.SendPort? sendPort]) async {
  var result = await _i4.run(args, _builders);
  sendPort?.send(result);
  _i5.exitCode = result;
}
