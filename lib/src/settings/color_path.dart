import 'dart:io';

import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class ColorPath {
  const ColorPath(this._path);

  final String _path;

  String get path => _path;

  File get file => File(_path);

  String get mime => lookupMimeType(_path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isXml => mime == 'application/xml';

  bool get isJson => mime == 'application/json';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorPath &&
          runtimeType == other.runtimeType &&
          _path == other._path;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _path.hashCode;
}
