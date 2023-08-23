
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:mime_type/mime_type.dart' as mime_type;

class StringPath {
  StringPath(this.path);

  final String path;

  File get file => File(path);

  String? get mime => lookupMimeType(path) ?? mime_type.mime(path);

  bool get isYaml => mime == 'application/x-yaml';

  bool get isJson => mime == 'application/json';

  bool get isCsv => mime == 'text/csv';

}

/*
import 'dart:io';

import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class ColorPath {
  const ColorPath(this.path);

  final String path;

  File get file => File(path);

  String? get mime => lookupMimeType(path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isXml => mime == 'application/xml';
}

 */