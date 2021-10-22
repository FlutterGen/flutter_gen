/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// ignore_for_file: directives_ordering

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

class $AssetsRiveGen {
  const $AssetsRiveGen();

  /// File path: assets/rive/vehicles.riv
  RiveGenImage get vehicles => const RiveGenImage('assets/rive/vehicles.riv');
}

class Assets {
  Assets._();

  static const $AssetsRiveGen rive = $AssetsRiveGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
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

  String get path => assetName;
}

class RiveGenImage {
  const RiveGenImage(this._assetName);

  final String _assetName;

  RiveAnimation rive({
    String? artboard,
    List<String> animations = const [],
    List<String> stateMachines = const [],
    BoxFit? fit,
    Alignment? alignment,
    Widget? placeHolder,
    bool antialiasing = true,
    List<RiveAnimationController> controllers = const [],
    OnInitCallback? onInit,
  }) {
    return RiveAnimation.asset(
      _assetName,
      artboard: artboard,
      animations: animations,
      stateMachines: stateMachines,
      fit: fit,
      alignment: alignment,
      placeHolder: placeHolder,
      antialiasing: antialiasing,
      controllers: controllers,
      onInit: onInit,
    );
  }

  String get path => _assetName;
}
