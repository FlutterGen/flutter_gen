import 'dart:io';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/generator_helper.dart';
import 'package:flutter_gen/src/settings/asset_path.dart';
import 'package:flutter_gen/src/settings/flutter/flutter_assets.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';

class AssetsGenerator {
  static String generate(FlutterAssets flutterAssets) {
    if (flutterAssets == null) {
      throw InvalidInputException;
    }

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
    return Image(image: this, frameBuilder: frameBuilder);
  }

  String get path => _assetName;
}
''');
    buffer.writeln('class Asset {');
    buffer.writeln('  Asset._();');
    buffer.writeln();

    for (final assetName in flutterAssets.assets) {
      final asset = AssetPath(assetName);
      if (asset.isDirectory) {
        Directory(assetName).listSync().forEach((entity) {
          final asset = AssetPath(entity.path);
          if (asset.isSupportedImage) {
            buffer.writeln(
                '  static AssetGenImage ${camelCase(asset.path)} = const AssetGenImage\(\'${asset.path}\'\);');
          } else if (!asset.isDirectory && !asset.isUnKnownMime) {
            buffer.writeln(
                '  static const String ${camelCase(asset.path)} = \'${asset.path}\'\;');
          }
        });
      } else {
        if (asset.isSupportedImage) {
          buffer.writeln(
              '  static AssetGenImage ${camelCase(asset.path)} = const AssetGenImage\(\'${asset.path}\'\);');
        } else {
          buffer.writeln(
              '  static const String ${camelCase(asset.path)} = \'${asset.path}\'\;');
        }
      }
    }

    buffer.writeln('}');
    return DartFormatter().format(buffer.toString());
  }
}
