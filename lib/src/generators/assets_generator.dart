import 'dart:collection';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/asset_type.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:path/path.dart';

String generateAssets(
    File pubspecFile, DartFormatter formatter, FlutterAssets assets) {
  assert(assets != null && assets.hasAssets,
      throw 'The value of "flutter/assets:" is incorrect.');

  final buffer = StringBuffer();
  buffer.writeln(header());
  buffer.writeln(_assetGenImageDefinition);

  final assetRelativePathList = _getAssetsRelativePathList(pubspecFile, assets);
  final assetTypeQueue = ListQueue<AssetType>.from(
      _constructAssetTree(assetRelativePathList).children);
  final assetsStaticStatements = <String>[];

  while (assetTypeQueue.isNotEmpty) {
    final assetType = assetTypeQueue.removeFirst();
    final assetAbsolutePath = join(pubspecFile.parent.path, assetType.path);

    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      final statements =
          _extractDirectoryClassGenStatements(pubspecFile, assetType);

      if (assetType.isDefaultAssetsDirectory) {
        for (final statement in statements) {
          assetsStaticStatements.add('  static $statement');
        }
      } else {
        final className = '\$${assetType.path.camelCase().capitalize()}Gen';
        _writeDirectoryClassGen(buffer, className, statements);
        // Add this directory reference to Assets class if we are not under the default asset folder
        if (dirname(assetType.path) == '.') {
          assetsStaticStatements.add(
              '  static $className get ${assetType.baseName.camelCase()} => $className\(\);');
        }
      }

      assetTypeQueue.addAll(assetType.children);
    }
  }

  // Begin writing Assets class
  buffer.writeln('class Assets {');
  buffer.writeln('  const Assets._();');
  assetsStaticStatements.forEach(buffer.writeln);
  buffer.writeln('}');
  // End writing Assets class

  return formatter.format(buffer.toString());
}

List<String> _getAssetsRelativePathList(
  File pubspecFile,
  FlutterAssets assets,
) {
  final assetRelativePathList = <String>[];
  for (final assetName in assets.assets) {
    final assetAbsolutePath = join(pubspecFile.parent.path, assetName);
    if (FileSystemEntity.isDirectorySync(assetAbsolutePath)) {
      assetRelativePathList.addAll(Directory(assetAbsolutePath)
          .listSync()
          .whereType<File>()
          .map((e) => relative(e.path, from: pubspecFile.parent.path))
          .toList());
    } else if (FileSystemEntity.isFileSync(assetAbsolutePath)) {
      assetRelativePathList
          .add(relative(assetAbsolutePath, from: pubspecFile.parent.path));
    }
  }
  return assetRelativePathList;
}

AssetType _constructAssetTree(List<String> assetRelativePathList) {
  // Relative path is the key
  final assetTypeMap = <String, AssetType>{
    '.': AssetType('.'),
  };
  for (final assetPath in assetRelativePathList) {
    var path = assetPath;
    while (path != '.') {
      assetTypeMap.putIfAbsent(path, () => AssetType(path));
      path = dirname(path);
    }
  }
  // Construct the AssetType tree
  for (final assetType in assetTypeMap.values) {
    if (assetType.path == '.') {
      continue;
    }
    final parentPath = dirname(assetType.path);
    assetTypeMap[parentPath].addChild(assetType);
  }
  return assetTypeMap['.'];
}

void _writeDirectoryClassGen(
  StringBuffer buffer,
  String className,
  List<String> statements,
) {
  buffer.writeln('''
class $className {
  factory $className() {
    _instance ??= const $className._();
    return _instance;
  }
  const $className._();
  static $className _instance;
''');

  for (final statement in statements) {
    buffer.writeln('  $statement');
  }

  buffer.writeln('}');
}

List<String> _extractDirectoryClassGenStatements(
  File pubspecFile,
  AssetType assetType,
) {
  final statements = assetType.children
      .map((child) {
        final childAssetAbsolutePath =
            join(pubspecFile.parent.path, child.path);
        String statement;
        if (child.isSupportedImage) {
          statement =
              'AssetGenImage get ${child.baseName.camelCase()} => const AssetGenImage\(\'${child.path}\'\);';
        } else if (FileSystemEntity.isDirectorySync(childAssetAbsolutePath)) {
          final childClassName = '\$${child.path.camelCase().capitalize()}Gen';
          statement =
              '$childClassName get ${child.baseName.camelCase()} => $childClassName\(\);';
        } else if (!child.isUnKnownMime) {
          statement =
              'String get ${child.baseName.camelCase()} => \'${child.path}\'\;';
        }
        return statement;
      })
      .whereType<String>()
      .toList();
  return statements;
}

const String _assetGenImageDefinition = '''
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
''';
