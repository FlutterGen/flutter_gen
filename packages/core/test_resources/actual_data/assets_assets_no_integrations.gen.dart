// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $PicturesGen {
  const $PicturesGen();

  /// File path: pictures/chip5.jpg
  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [chip5];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/chip1.jpg
  AssetGenImage get chip1 => const AssetGenImage('assets/images/chip1.jpg');

  /// File path: assets/images/chip2.jpg
  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');

  /// Directory path: assets/images/chip3
  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();

  /// Directory path: assets/images/chip4
  $AssetsImagesChip4Gen get chip4 => const $AssetsImagesChip4Gen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/profile.jpg
  AssetGenImage get profileJpg =>
      const AssetGenImage('assets/images/profile.jpg');

  /// File path: assets/images/profile.png
  AssetGenImage get profilePng =>
      const AssetGenImage('assets/images/profile.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    chip1,
    chip2,
    logo,
    profileJpg,
    profilePng,
  ];
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/list.json
  String get list => 'assets/json/list.json';

  /// File path: assets/json/map.json
  String get map => 'assets/json/map.json';

  /// List of all assets
  List<String> get values => [list, map];
}

class $AssetsImagesChip3Gen {
  const $AssetsImagesChip3Gen();

  /// File path: assets/images/chip3/chip3.jpg
  AssetGenImage get chip3 =>
      const AssetGenImage('assets/images/chip3/chip3.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [chip3];
}

class $AssetsImagesChip4Gen {
  const $AssetsImagesChip4Gen();

  /// File path: assets/images/chip4/chip4.jpg
  AssetGenImage get chip4 =>
      const AssetGenImage('assets/images/chip4/chip4.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [chip4];
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/dart@test.svg
  String get dartTest => 'assets/images/icons/dart@test.svg';

  /// File path: assets/images/icons/fuchsia.svg
  String get fuchsia => 'assets/images/icons/fuchsia.svg';

  /// File path: assets/images/icons/kmm.svg
  String get kmm => 'assets/images/icons/kmm.svg';

  /// File path: assets/images/icons/paint.svg
  String get paint => 'assets/images/icons/paint.svg';

  /// List of all assets
  List<String> get values => [dartTest, fuchsia, kmm, paint];
}

class Assets {
  const Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $PicturesGen pictures = $PicturesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
