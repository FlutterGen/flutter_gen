import 'package:dartx/dartx.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class AssetType {
  AssetType({required this.rootPath, required this.path});

  final String rootPath;
  final String path;

  final List<AssetType> _children = List.empty(growable: true);

  bool get isDefaultAssetsDirectory => path == 'assets' || path == 'asset';

  String? get mime => lookupMimeType(path);

  bool get isIgnoreFile {
    switch (baseName) {
      case '.DS_Store':
        return true;
    }

    switch (extension) {
      case '.DS_Store':
      case '.swp':
        return true;
    }

    return false;
  }

  bool get isUnKnownMime => mime == null;

  String get extension => p.extension(path);

  String get baseName => p.basenameWithoutExtension(path);

  List<AssetType> get children => _children.sortedBy((e) => e.path);

  void addChild(AssetType type) {
    _children.add(type);
  }
}

class AssetTypeIsUniqueWithoutExtension {
  AssetTypeIsUniqueWithoutExtension({
    required this.assetType,
    required this.isUniqueWithoutExtension,
  });

  final AssetType assetType;
  final bool isUniqueWithoutExtension;
}

extension AssetTypeIterable on Iterable<AssetType> {
  Iterable<AssetTypeIsUniqueWithoutExtension> mapToIsUniqueWithoutExtension() {
    return groupBy((e) => p.withoutExtension(e.path))
        .values
        .map(
          (list) => list.map(
            (e) => AssetTypeIsUniqueWithoutExtension(
              assetType: e,
              isUniqueWithoutExtension: list.length == 1,
            ),
          ),
        )
        .flatten();
  }
}
