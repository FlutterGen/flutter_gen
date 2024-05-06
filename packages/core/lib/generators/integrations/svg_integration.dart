import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class SvgIntegration extends Integration {
  SvgIntegration(String packageName, {super.parseMetadata})
      : super(packageName);

  String get packageExpression => isPackage ? ' = package' : '';

  @override
  List<String> get requiredImports => [
        'package:flutter/widgets.dart',
        'package:flutter/services.dart',
        'package:flutter_svg/flutter_svg.dart',
        'package:vector_graphics/vector_graphics.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size = null,
  }) : _isVecFormat = false;
  
  const SvgGenImage.vec(
    this._assetName, {
    this.size = null,
  }) : _isVecFormat = true;

  final String _assetName;
${isPackage ? "\n  static const String package = '$packageName';" : ''}

  final Size? size;
  final bool _isVecFormat;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    ${isPackage ? deprecationMessagePackage : ''}
    String? package$packageExpression,
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
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture(
      _isVecFormat ? 
        AssetBytesLoader(_assetName, assetBundle: bundle, packageName: package) :
        SvgAssetLoader(_assetName, assetBundle: bundle, packageName: package),
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
      theme: theme,
      colorFilter: colorFilter ?? (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => ${isPackage ? '\'packages/$packageName/\$_assetName\'' : '_assetName'};
}''';

  @override
  String get className => 'SvgGenImage';

  @override
  String classInstantiate(AssetType asset) {
    // Query extra information about the SVG
    ImageMetadata? info = parseMetadata ? _getMetadata(asset) : null;

    final String constructorName =
        asset.extension == '.vec' ? 'SvgGenImage.vec' : 'SvgGenImage';

    return "$constructorName('${asset.posixStylePath}'"
        "${(info != null) ? ', size: Size(${info.width}, ${info.height})' : ''}"
        ')';
  }

  ImageMetadata? _getMetadata(AssetType asset) {
    try {
      // The SVG file is read fully, then parsed with the vector_graphics
      // library. This is quite a heavy way to extract just the dimenions, but
      // it's also the same way it will be eventually rendered by Flutter.
      final svg = File(asset.fullPath).readAsStringSync();
      final vec = parseWithoutOptimizers(svg);
      return ImageMetadata(vec.width, vec.height);
    } catch (e) {
      stderr.writeln(
          '[WARNING] Failed to parse SVG \'${asset.path}\' metadata: $e');
    }

    return null;
  }

  @override
  bool isSupport(AssetType asset) =>
      asset.mime == 'image/svg+xml' || asset.extension == '.vec';

  @override
  bool get isConstConstructor => true;
}
