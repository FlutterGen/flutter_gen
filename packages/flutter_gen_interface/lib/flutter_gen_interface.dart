import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.package,
    this.animation,
  });

  final String _assetName;
  final String? package;
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
      package: package ?? this.package,
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
      package: package ?? this.package,
    );
  }

  String get path => _assetName;

  String get keyName =>
      package == null ? _assetName : 'packages/$package/$_assetName';
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

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.package,
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.package,
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;
  final String? package;

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
    SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @Deprecated('Use colorFilter instead') Color? color,
    @Deprecated('Use colorFilter instead')
    BlendMode colorBlendMode = BlendMode.srcIn,
    @Deprecated('This no longer does anything') bool cacheColorFilter = false,
  }) {
    final bytesLoader = _isVecFormat
        ? AssetBytesLoader(
            _assetName,
            assetBundle: bundle,
            packageName: package ?? this.package,
          )
        : SvgAssetLoader(
            _assetName,
            assetBundle: bundle,
            packageName: package ?? this.package,
            theme: theme,
          );
    return SvgPicture(
      bytesLoader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      // ignore: deprecated_member_use
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName =>
      package == null ? _assetName : 'packages/$package/$_assetName';
}
