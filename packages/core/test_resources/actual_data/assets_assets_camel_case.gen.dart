// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class Assets {
  const Assets._();

  /// File path: assets/images/chip1.jpg
  static const AssetGenImage imagesChip1 = AssetGenImage(
    'assets/images/chip1.jpg',
  );

  /// File path: assets/images/chip2.jpg
  static const AssetGenImage imagesChip2 = AssetGenImage(
    'assets/images/chip2.jpg',
  );

  /// File path: assets/images/chip3/chip3.jpg
  static const AssetGenImage imagesChip3Chip3 = AssetGenImage(
    'assets/images/chip3/chip3.jpg',
  );

  /// File path: assets/images/chip4/chip4.jpg
  static const AssetGenImage imagesChip4Chip4 = AssetGenImage(
    'assets/images/chip4/chip4.jpg',
  );

  /// File path: assets/images/icons/dart@test.svg
  static const String imagesIconsDartTest = 'assets/images/icons/dart@test.svg';

  /// File path: assets/images/icons/fuchsia.svg
  static const String imagesIconsFuchsia = 'assets/images/icons/fuchsia.svg';

  /// File path: assets/images/icons/kmm.svg
  static const String imagesIconsKmm = 'assets/images/icons/kmm.svg';

  /// File path: assets/images/icons/paint.svg
  static const String imagesIconsPaint = 'assets/images/icons/paint.svg';

  /// File path: assets/images/logo.png
  static const AssetGenImage imagesLogo = AssetGenImage(
    'assets/images/logo.png',
  );

  /// File path: assets/images/profile.jpg
  static const AssetGenImage imagesProfileJpg = AssetGenImage(
    'assets/images/profile.jpg',
  );

  /// File path: assets/images/profile.png
  static const AssetGenImage imagesProfilePng = AssetGenImage(
    'assets/images/profile.png',
  );

  /// File path: assets/json/list.json
  static const String jsonList = 'assets/json/list.json';

  /// File path: assets/json/map.json
  static const String jsonMap = 'assets/json/map.json';

  /// File path: pictures/chip5.jpg
  static const AssetGenImage picturesChip5 = AssetGenImage(
    'pictures/chip5.jpg',
  );

  /// List of all assets
  static List<dynamic> get values => [
    imagesChip1,
    imagesChip2,
    imagesChip3Chip3,
    imagesChip4Chip4,
    imagesIconsDartTest,
    imagesIconsFuchsia,
    imagesIconsKmm,
    imagesIconsPaint,
    imagesLogo,
    imagesProfileJpg,
    imagesProfilePng,
    jsonList,
    jsonMap,
    picturesChip5,
  ];
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
