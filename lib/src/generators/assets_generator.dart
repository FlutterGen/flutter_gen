import 'dart:collection';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/asset_type.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:path/path.dart';

class AssetsGenerator {
  static String generate(
      File pubspecFile, DartFormatter formatter, FlutterAssets assets) {
    assert(assets != null && assets.hasAssets,
        throw 'The value of "flutter/assets:" is incorrect.');

    final buffer = StringBuffer();
    buffer.writeln(header());
    buffer.writeln('''
import 'package:flutter/widgets.dart';

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName)
      : _assetName = assetName,
        super(assetName);
  final String _assetName;

  Image image({
    ImageFrameBuilder frameBuilder,
    ImageLoadingBuilder loadingBuilder,
    ImageErrorWidgetBuilder errorBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => _assetName;
}
''');

    final assetPathList = <String>[];
    for (final assetName in assets.assets) {
      final assetPath = join(pubspecFile.parent.path, assetName);
      if (FileSystemEntity.isDirectorySync(assetPath)) {
        assetPathList.addAll(Directory(assetPath)
            .listSync()
            .whereType<File>()
            .map((e) => relative(e.path, from: pubspecFile.parent.path))
            .toList());
      } else if (FileSystemEntity.isFileSync(assetPath)) {
        assetPathList.add(relative(assetPath, from: pubspecFile.parent.path));
      }
    }

    final assetTypeMap = <String, AssetType>{
      '.': AssetType('.'),
    };
    for (final assetPath in assetPathList) {
      print(assetPath);
      var path = assetPath;
      while (path != '.' && path != null) {
        assetTypeMap.putIfAbsent(path, () => AssetType(path));
        path = FileSystemEntity.parentOf(path);
      }
    }
    for (final assetType in assetTypeMap.values) {
      if (assetType.path == '.') {
        continue;
      }
      final parentPath = FileSystemEntity.parentOf(assetType.path);
      print(parentPath);
      print(assetType.path);
      print('');
      assetTypeMap[parentPath].addChild(assetType);
    }

    final root = assetTypeMap['.'];
    final assetTypeQueue = ListQueue<AssetType>.from(root.children);

    while (!assetTypeQueue.isEmpty) {
      final assetType = assetTypeQueue.removeFirst();
      final assetPath = join(pubspecFile.parent.path, assetType.path);
      if (FileSystemEntity.isDirectorySync(assetPath)) {
        final className = assetType.path.camelCase().capitalize();
        buffer.writeln('''
class $className {
  factory $className() {
    _instance ??= const $className._();
    return _instance;
  }
  const $className._();
  static $className _instance;
''');
        for (final child in assetType.children) {
          final childAssetPath = join(pubspecFile.parent.path, child.path);
          if (child.isSupportedImage) {
            buffer.writeln(
                '  AssetGenImage get ${child.baseName.camelCase()} => const AssetGenImage\(\'${child.path}\'\);');
          } else if (FileSystemEntity.isDirectorySync(childAssetPath)) {
            buffer.writeln(
                '  ${child.path.camelCase().capitalize()} get ${child.baseName.camelCase()} => ${child.path.camelCase().capitalize()}\(\);');
          } else if (!child.isUnKnownMime) {
            buffer.writeln(
                '  String get ${child.baseName.camelCase()} => \'${child.path}\'\;');
          }
          assetTypeQueue.add(child);
        }

        buffer.writeln('}');
      }
    }

    return formatter.format(buffer.toString());
  }
}
