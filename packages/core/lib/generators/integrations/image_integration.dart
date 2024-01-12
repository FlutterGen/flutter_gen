import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

/// The main image integration, supporting all image asset types. See
/// [isSupport] for the exact supported mime types.
///
/// This integration is by enabled by default.
class ImageIntegration extends Integration {
  ImageIntegration(String packageName, {super.parseMetadata})
      : super(packageName);

  String get packageParameter => isPackage ? ' = package' : '';

  String get keyName =>
      isPackage ? "'packages/$packageName/\$_assetName'" : '_assetName';

  @override
  List<String> get requiredImports => ['package:flutter/widgets.dart'];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size = null});

  final String _assetName;
${isPackage ? "\n  static const String package = '$packageName';" : ''}

  final Size? size;

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
  String classInstantiate(AssetType asset) {
    ImageMetadata? info = parseMetadata ? _getMetadata(asset) : null;

    return 'AssetGenImage(\'${asset.posixStylePath}\''
        '${(info != null) ? ', size: Size(${info.width}, ${info.height})' : ''}'
        ')';
  }

  @override
  bool isSupport(AssetType asset) {
    /// Flutter official supported image types. See
    /// https://api.flutter.dev/flutter/widgets/Image-class.html
    switch (asset.mime) {
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

  /// Extract metadata from the asset.
  ImageMetadata? _getMetadata(AssetType asset) {
    try {
      final size = ImageSizeGetter.getSize(FileInput(File(asset.fullPath)));
      return ImageMetadata(size.width.toDouble(), size.height.toDouble());
    } catch (e) {
      stderr
          .writeln('[WARNING] Failed to parse \'${asset.path}\' metadata: $e');
    }
    return null;
  }
}
