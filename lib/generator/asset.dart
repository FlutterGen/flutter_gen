import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class Asset {
  Asset(this._path) {
    this._mime = lookupMimeType(this._path);
  }

  final String _path;

  String get path => _path;

  String _mime;

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isImage {
    switch (_mime) {
      case 'image/jpeg':
      case 'image/png':
      case 'image/gif':
      case 'image/bmp':
      case 'image/vnd.wap.wbmp':
      case 'image/webp':
        return true;
      default:
        return false;
    }
  }
}
