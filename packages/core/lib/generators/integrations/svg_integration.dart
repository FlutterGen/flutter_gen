import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class SvgIntegration extends Integration {
  SvgIntegration(String packageName, {this.parseMetadata = false})
      : super(packageName);

  String get packageExpression => isPackage ? ' = package' : '';

  final bool parseMetadata;

  @override
  List<String> get requiredImports => [
        'package:flutter/widgets.dart',
        'package:flutter_svg/flutter_svg.dart',
        'package:flutter/services.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size = null});

  final String _assetName;
  final Size? size;
${isPackage ? "\n  static const String package = '$packageName';" : ''}

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

  String get keyName => ${isPackage ? '\'packages/$packageName/\$_assetName\'' : '_assetName'};
}''';

  @override
  String get className => 'SvgGenImage';

  @override
  String classInstantiate(AssetType asset) {
    // Query extra information about the SVG
    SvgInfo? info = parseMetadata ? _getMetadata(asset) : null;

    return 'SvgGenImage(\'${asset.posixStylePath}\''
        '${(info != null) ? ', size: Size(${info.width}, ${info.height})' : ''}'
        ')';
  }

  SvgInfo? _getMetadata(AssetType asset) {
    try {
      // The SVG file is read fully, then parsed with the vector_graphics
      // library. This is quite a heavy way to extract just the dimenions, but
      // it's also the same way it will be eventually rendered by Flutter.
      final svg = File(asset.fullPath).readAsStringSync();
      final vec = parseWithoutOptimizers(svg);
      return SvgInfo(vec.width, vec.height);
    } catch (e) {
      stderr.writeln(
          '[WARNING] Failed to parse SVG \'${asset.path}\' metadata: $e');
    }

    return null;
  }

  @override
  bool isSupport(AssetType asset) => asset.mime == 'image/svg+xml';

  @override
  bool get isConstConstructor => true;
}

/// Useful metadata about the a parsed SVG file.
/// Currently only contains the width and height.
class SvgInfo {
  final double width;
  final double height;

  SvgInfo(this.width, this.height);
}
