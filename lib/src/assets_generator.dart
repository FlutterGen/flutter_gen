import 'dart:io';

import 'package:build/build.dart';
import 'package:flutter_gen/src/asset.dart';
import 'package:flutter_gen/src/camel_case.dart';
import 'package:yaml/yaml.dart';

class AssetsGenerator {
  static String generate(YamlList assetsList) {
    if (assetsList == null) {
      throw InvalidInputException;
    }

    final buffer = StringBuffer();
    buffer.writeln('/// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('/// *****************************************************');
    buffer.writeln('///  FlutterGen');
    buffer.writeln('/// *****************************************************');
    buffer.writeln();

    buffer.writeln("import 'package:flutter/widgets.dart';");
    buffer.writeln();
    buffer.writeln('class AssetGenImage extends AssetImage {');
    buffer.writeln('  const AssetGenImage(String assetName)');
    buffer.writeln('      : _assetName = assetName,');
    buffer.writeln('        super(assetName);');
    buffer.writeln('  final String _assetName;');
    buffer.writeln();
    buffer.writeln('  Image image({');
    buffer.writeln('    ImageFrameBuilder frameBuilder,');
    buffer.writeln('    ImageLoadingBuilder loadingBuilder,');
    buffer.writeln('    ImageErrorWidgetBuilder errorBuilder,');
    buffer.writeln('    String semanticLabel,');
    buffer.writeln('    bool excludeFromSemantics = false,');
    buffer.writeln('    double width,');
    buffer.writeln('    double height,');
    buffer.writeln('    Color color,');
    buffer.writeln('    BlendMode colorBlendMode,');
    buffer.writeln('    BoxFit fit,');
    buffer.writeln('    AlignmentGeometry alignment = Alignment.center,');
    buffer.writeln('    ImageRepeat repeat = ImageRepeat.noRepeat,');
    buffer.writeln('    Rect centerSlice,');
    buffer.writeln('    bool matchTextDirection = false,');
    buffer.writeln('    bool gaplessPlayback = false,');
    buffer.writeln('    bool isAntiAlias = false,');
    buffer.writeln('    FilterQuality filterQuality = FilterQuality.low,');
    buffer.writeln('  }) {');
    buffer
        .writeln('    return Image(image: this, frameBuilder: frameBuilder);');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  String get path => _assetName;');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('class Asset {');
    buffer.writeln('  Asset._();');

    final files = <Asset>[];
    for (final assetName in assetsList.cast<String>()) {
      if (FileSystemEntity.isDirectorySync(assetName)) {
        Directory(assetName).listSync().forEach((entity) {
          final asset = Asset(entity.path);
          if (asset.isImage) {
            buffer.writeln(
                '  static AssetGenImage ${CamelCase.from(asset.path)} = ');
            buffer.writeln('      const AssetGenImage\(\'${asset.path}\'\);');
          }
        });
      } else {
        final asset = Asset(assetName);
        if (asset.isImage) {
          files.add(asset);
        }
      }
    }

    buffer.write('}');
    return buffer.toString();
  }
}
