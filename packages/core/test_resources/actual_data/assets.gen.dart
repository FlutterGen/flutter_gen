/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';

class $PicturesGen {
  const $PicturesGen();

  /// File path: pictures/chip5.jpg
  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [chip5];
}

class $AssetsFlareGen {
  const $AssetsFlareGen();

  /// File path: assets/flare/Penguin.flr
  FlareGenImage get penguin => const FlareGenImage('assets/flare/Penguin.flr');

  /// List of all assets
  List<FlareGenImage> get values => [penguin];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/chip1.jpg
  AssetGenImage get chip1 => const AssetGenImage('assets/images/chip1.jpg');

  /// File path: assets/images/chip2.jpg
  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');

  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();
  $AssetsImagesChip4Gen get chip4 => const $AssetsImagesChip4Gen();
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
  List<AssetGenImage> get values =>
      [chip1, chip2, logo, profileJpg, profilePng];
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

class $AssetsMovieGen {
  const $AssetsMovieGen();

  /// File path: assets/movie/the_earth.mp4
  String get theEarth => 'assets/movie/the_earth.mp4';

  /// List of all assets
  List<String> get values => [theEarth];
}

class $AssetsUnknownGen {
  const $AssetsUnknownGen();

  /// File path: assets/unknown/unknown_mime_type.bk
  String get unknownMimeType => 'assets/unknown/unknown_mime_type.bk';

  /// List of all assets
  List<String> get values => [unknownMimeType];
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
  SvgGenImage get dartTest =>
      const SvgGenImage('assets/images/icons/dart@test.svg');

  /// File path: assets/images/icons/fuchsia.svg
  SvgGenImage get fuchsia =>
      const SvgGenImage('assets/images/icons/fuchsia.svg');

  /// File path: assets/images/icons/kmm.svg
  SvgGenImage get kmm => const SvgGenImage('assets/images/icons/kmm.svg');

  /// File path: assets/images/icons/paint.svg
  SvgGenImage get paint => const SvgGenImage('assets/images/icons/paint.svg');

  /// List of all assets
  List<SvgGenImage> get values => [dartTest, fuchsia, kmm, paint];
}

class Assets {
  Assets._();

  static const $AssetsFlareGen flare = $AssetsFlareGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $AssetsMovieGen movie = $AssetsMovieGen();
  static const $AssetsUnknownGen unknown = $AssetsUnknownGen();
  static const $PicturesGen pictures = $PicturesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

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
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
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

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme theme = const SvgTheme(),
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture.asset(
      _assetName,
      key: key,
      matchTextDirection: matchTextDirection,
      bundle: bundle,
      package: package,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      theme: theme,
      colorFilter: colorFilter,
      color: color,
      colorBlendMode: colorBlendMode,
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class FlareGenImage {
  const FlareGenImage(this._assetName);

  final String _assetName;

  FlareActor flare({
    String? boundsNode,
    String? animation,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool isPaused = false,
    bool snapToEnd = false,
    FlareController? controller,
    FlareCompletedCallback? callback,
    Color? color,
    bool shouldClip = true,
    bool sizeFromArtboard = false,
    String? artboard,
    bool antialias = true,
  }) {
    return FlareActor(
      _assetName,
      boundsNode: boundsNode,
      animation: animation,
      fit: fit,
      alignment: alignment,
      isPaused: isPaused,
      snapToEnd: snapToEnd,
      controller: controller,
      callback: callback,
      color: color,
      shouldClip: shouldClip,
      sizeFromArtboard: sizeFromArtboard,
      artboard: artboard,
      antialias: antialias,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
