import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/asset_type.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';

class AssetsGenerator {
  static String generate(DartFormatter formatter, FlutterAssets assets) {
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
    buffer.writeln('class Asset {');
    buffer.writeln('  Asset._();');
    buffer.writeln();

    final assetList = <AssetType>[];
    for (final assetName in assets.assets) {
      final asset = AssetType(assetName);
      if (asset.isDirectory) {
        assetList.addAll(Directory(assetName)
            .listSync()
            .map((entity) => AssetType(entity.path))
            .toList());
      } else {
        assetList.add(asset);
      }
    }

    // to Set<> for remove duplicated item
    for (final assetType in {...assetList}) {
      final path = assetType.path;
      if (assetType.isSupportedImage) {
        buffer.writeln(
            '  static AssetGenImage ${camelCase(path)} = const AssetGenImage\(\'$path\'\);');
      } else if (!assetType.isDirectory && !assetType.isUnKnownMime) {
        buffer
            .writeln('  static const String ${camelCase(path)} = \'$path\'\;');
      }
    }

    buffer.writeln('}');
    return formatter.format(buffer.toString());
  }
}
