import 'dart:io';

import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class ColorPath {
  ColorPath(this._path) {
    _mime = lookupMimeType(_path);
  }

  final String _path;

  String get path => _path;

  File get file => File(_path);

  String _mime;

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isXml => _mime == 'application/xml';

  bool get isJson => _mime == 'application/json';
}
