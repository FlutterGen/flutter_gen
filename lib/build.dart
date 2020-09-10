import 'dart:io';

import 'package:build/build.dart';

import 'src/flutter_generator.dart';

Builder build(BuilderOptions options) {
  Future(() async {
    await FlutterGenerator(File('pubspec.yaml')).build();
  });
  return EmptyBuilder();
}

class EmptyBuilder extends Builder {
  @override
  Future<void> build(BuildStep buildStep) async {}

  @override
  Map<String, List<String>> get buildExtensions => {};
}
