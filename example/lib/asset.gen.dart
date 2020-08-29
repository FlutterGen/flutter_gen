/// GENERATED CODE - DO NOT MODIFY BY HAND

/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/widgets.dart';

class AssetGenImage extends AssetImage {
  AssetGenImage(String assetName)
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

class Asset {
  Asset._();
  static AssetGenImage chip2 = AssetGenImage("assets/images/chip2.jpg");
  static AssetGenImage chip1 = AssetGenImage("assets/images/chip1.jpg");
  static AssetGenImage logo = AssetGenImage("assets/images/logo.png");
  static AssetGenImage profile = AssetGenImage("assets/images/profile.jpg");
  static AssetGenImage chip3 = AssetGenImage("assets/images/chip/chip3.jpg");
}
