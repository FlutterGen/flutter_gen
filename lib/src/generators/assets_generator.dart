import 'dart:io';

import 'package:build/build.dart';
import 'package:flutter_gen/src/generators/generator.dart';
import 'package:flutter_gen/src/settings/asset.dart';
import 'package:flutter_gen/src/utils/camel_case.dart';
import 'package:yaml/yaml.dart';

class AssetsGenerator {
  static String generate(YamlList assetsList) {
    if (assetsList == null) {
      throw InvalidInputException;
    }

    final buffer = StringBuffer();
    buffer.writeln(header());
    buffer.writeln();
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

    final files = <Asset>[];
    for (final assetName in assetsList.cast<String>()) {
      if (FileSystemEntity.isDirectorySync(assetName)) {
        Directory(assetName).listSync().forEach((entity) {
          final asset = Asset(entity.path);
          if (asset.isImage) {
            buffer.writeln(
                '  static AssetGenImage ${CamelCase.from(asset.path)} = const AssetGenImage\(\'${asset.path}\'\);');
          }
        });
      } else {
        final asset = Asset(assetName);
        if (asset.isImage) {
          files.add(asset);
        }
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }
}
