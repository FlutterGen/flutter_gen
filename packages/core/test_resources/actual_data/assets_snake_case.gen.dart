/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class Assets {
  Assets._();

  /// File path: assets/images/chip1.jpg
  static const AssetGenImage images_chip1 =
      AssetGenImage('assets/images/chip1.jpg');

  /// File path: assets/images/chip2.jpg
  static const AssetGenImage images_chip2 =
      AssetGenImage('assets/images/chip2.jpg');

  /// File path: assets/images/chip3/chip3.jpg
  static const AssetGenImage images_chip3_chip3 =
      AssetGenImage('assets/images/chip3/chip3.jpg');

  /// File path: assets/images/chip4/chip4.jpg
  static const AssetGenImage images_chip4_chip4 =
      AssetGenImage('assets/images/chip4/chip4.jpg');

  /// File path: assets/images/icons/dart@test.svg
  static const String images_icons_dart_test =
      'assets/images/icons/dart@test.svg';

  /// File path: assets/images/icons/fuchsia.svg
  static const String images_icons_fuchsia = 'assets/images/icons/fuchsia.svg';

  /// File path: assets/images/icons/kmm.svg
  static const String images_icons_kmm = 'assets/images/icons/kmm.svg';

  /// File path: assets/images/icons/paint.svg
  static const String images_icons_paint = 'assets/images/icons/paint.svg';

  /// File path: assets/images/logo.png
  static const AssetGenImage images_logo =
      AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/profile.jpg
  static const AssetGenImage images_profile_jpg =
      AssetGenImage('assets/images/profile.jpg');

  /// File path: assets/images/profile.png
  static const AssetGenImage images_profile_png =
      AssetGenImage('assets/images/profile.png');

  /// File path: assets/json/list.json
  static const String json_list = 'assets/json/list.json';

  /// File path: assets/json/map.json
  static const String json_map = 'assets/json/map.json';

  /// File path: pictures/chip5.jpg
  static const AssetGenImage pictures_chip5 =
      AssetGenImage('pictures/chip5.jpg');

  /// List of all assets
  List<dynamic> get values => [
        images_chip1,
        images_chip2,
        images_chip3_chip3,
        images_chip4_chip4,
        images_icons_dart_test,
        images_icons_fuchsia,
        images_icons_kmm,
        images_icons_paint,
        images_logo,
        images_profile_jpg,
        images_profile_png,
        json_list,
        json_map,
        pictures_chip5
      ];
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
