/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class $PicturesGen {
  const $PicturesGen();

  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  AssetGenImage get chip1 => const AssetGenImage('assets/images/chip1.jpg');
  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');
  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();
  $AssetsImagesChip4Gen get chip4 => const $AssetsImagesChip4Gen();
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');
  AssetGenImage get profile => const AssetGenImage('assets/images/profile.jpg');
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  String get fruits => 'assets/json/fruits.json';
}

class $AssetsImagesChip3Gen {
  const $AssetsImagesChip3Gen();

  AssetGenImage get chip3 =>
      const AssetGenImage('assets/images/chip3/chip3.jpg');
}

class $AssetsImagesChip4Gen {
  const $AssetsImagesChip4Gen();

  AssetGenImage get chip4 =>
      const AssetGenImage('assets/images/chip4/chip4.jpg');
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  SvgGenImage get fuchsia =>
      const SvgGenImage('assets/images/icons/fuchsia.svg');
  SvgGenImage get kmm => const SvgGenImage('assets/images/icons/kmm.svg');
  SvgGenImage get paint => const SvgGenImage('assets/images/icons/paint.svg');
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $PicturesGen pictures = $PicturesGen();
}

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

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    bool matchTextDirection = false,
    AssetBundle bundle,
    String package,
    double width,
    double height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder placeholderBuilder,
    Color color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture.asset(
      _assetName,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      color: color,
      colorBlendMode: colorBlendMode,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
    );
  }

  String get path => _assetName;
}
