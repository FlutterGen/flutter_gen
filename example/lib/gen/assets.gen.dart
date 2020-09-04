/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

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

class $PicturesGen {
  factory $PicturesGen() {
    _instance ??= const $PicturesGen._();
    return _instance;
  }
  const $PicturesGen._();
  static $PicturesGen _instance;

  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');
}

class $AssetsImagesGen {
  factory $AssetsImagesGen() {
    _instance ??= const $AssetsImagesGen._();
    return _instance;
  }
  const $AssetsImagesGen._();
  static $AssetsImagesGen _instance;

  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');
  AssetGenImage get chip1 => const AssetGenImage('assets/images/chip1.jpg');
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');
  AssetGenImage get profile => const AssetGenImage('assets/images/profile.jpg');
  $AssetsImagesChip3Gen get chip3 => $AssetsImagesChip3Gen();
  $AssetsImagesChip4Gen get chip4 => $AssetsImagesChip4Gen();
  $AssetsImagesIconsGen get icons => $AssetsImagesIconsGen();
}

class $AssetsJsonGen {
  factory $AssetsJsonGen() {
    _instance ??= const $AssetsJsonGen._();
    return _instance;
  }
  const $AssetsJsonGen._();
  static $AssetsJsonGen _instance;

  String get fruits => 'assets/json/fruits.json';
}

class $AssetsImagesChip3Gen {
  factory $AssetsImagesChip3Gen() {
    _instance ??= const $AssetsImagesChip3Gen._();
    return _instance;
  }
  const $AssetsImagesChip3Gen._();
  static $AssetsImagesChip3Gen _instance;

  AssetGenImage get chip3 =>
      const AssetGenImage('assets/images/chip3/chip3.jpg');
}

class $AssetsImagesChip4Gen {
  factory $AssetsImagesChip4Gen() {
    _instance ??= const $AssetsImagesChip4Gen._();
    return _instance;
  }
  const $AssetsImagesChip4Gen._();
  static $AssetsImagesChip4Gen _instance;

  AssetGenImage get chip4 =>
      const AssetGenImage('assets/images/chip4/chip4.jpg');
}

class $AssetsImagesIconsGen {
  factory $AssetsImagesIconsGen() {
    _instance ??= const $AssetsImagesIconsGen._();
    return _instance;
  }
  const $AssetsImagesIconsGen._();
  static $AssetsImagesIconsGen _instance;

  String get paint => 'assets/images/icons/paint.svg';
}

class Assets {
  const Assets._();

  static $AssetsImagesGen get images => $AssetsImagesGen();
  static $AssetsJsonGen get json => $AssetsJsonGen();
  static $PicturesGen get pictures => $PicturesGen();
}
