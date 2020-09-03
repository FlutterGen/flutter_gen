import 'package:mime/mime.dart';
import 'package:path/path.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class AssetType {
  AssetType(this._path);

  final String _path;

  final List<AssetType> _children = List.empty(growable: true);

  String get path => _path;

  bool get isDefaultAssetsDirectory => _path == 'assets' || _path == 'asset';

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

  String get baseName => basenameWithoutExtension(_path);

  List<AssetType> get children => _children;

  void addChild(AssetType type) {
    _children.add(type);
  }
}
