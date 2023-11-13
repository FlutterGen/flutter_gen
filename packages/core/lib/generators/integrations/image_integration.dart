import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';

/// The main image integration, supporting all image asset types. See
/// [isSupport] for the exact supported mime types.
///
/// This integration is by enabled by default.
class ImageIntegration extends Integration {
  ImageIntegration(String packageName) : super(packageName);

  String get packageParameter => isPackage ? ' = package' : '';

  String get keyName =>
      isPackage ? "'packages/$packageName/\$_assetName'" : '_assetName';

  @override
  List<String> get requiredImports => ['package:flutter/widgets.dart'];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;
${isPackage ? "\n  static const String package = '$packageName';" : ''}

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
    ${isPackage ? deprecationMessagePackage : ''}
    String? package$packageParameter,
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
    ${isPackage ? deprecationMessagePackage : ''}
    String? package$packageParameter,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => $keyName;
}
''';

  @override
  String get className => 'AssetGenImage';

  @override
  String classInstantiate(String path) => 'AssetGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) {
    /// Flutter official supported image types. See
    /// https://api.flutter.dev/flutter/widgets/Image-class.html
    switch (type.mime) {
      case 'image/jpeg':
      case 'image/png':
      case 'image/gif':
      case 'image/bmp':
      case 'image/vnd.wap.wbmp':
      case 'image/webp':
        return true;
      default:
        return false;
    }
  }

  @override
  bool get isConstConstructor => true;
}
