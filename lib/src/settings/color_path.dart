import 'dart:io';

import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class ColorPath {
  const ColorPath(this.path);

  final String path;

  File get file => File(path);

  String get mime => lookupMimeType(path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isXml => mime == 'application/xml';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorPath &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => path.hashCode;
}
