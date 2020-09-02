import 'package:mime/mime.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class AssetType {
  const AssetType(this._path);

  final String _path;

  String get path => _path;

  String get mime => lookupMimeType(_path);

  /// https://api.flutter.dev/flutter/widgets/Image-class.html
  bool get isSupportedImage {
    switch (mime) {
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

  bool get isUnKnownMime => mime == null;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetType &&
          runtimeType == other.runtimeType &&
          _path == other._path;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _path.hashCode;
}
