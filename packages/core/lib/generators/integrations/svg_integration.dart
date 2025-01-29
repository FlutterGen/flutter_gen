import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class SvgIntegration extends Integration {
  SvgIntegration(String packageName, {super.parseMetadata})
      : super(packageName);

  String get packageExpression => isPackage ? ' = package' : '';

  @override
  List<Import> get requiredImports => const [
        Import('package:flutter/widgets.dart'),
        Import('package:flutter/services.dart'),
        Import('package:flutter_svg/flutter_svg.dart', alias: '_svg'),
        Import('package:vector_graphics/vector_graphics.dart', alias: '_vg'),
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;
  
  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    ${isPackage ? '$deprecationMessagePackage\n' : ''}String? package$packageExpression,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
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
    // Query extra information about the SVG.
    final info = parseMetadata ? _getMetadata(asset) : null;
    final buffer = StringBuffer(className);
    if (asset.extension == '.vec') {
      buffer.write('.vec');
    }
    buffer.write('(');
    buffer.write('\'${asset.posixStylePath}\'');
    if (info != null) {
      buffer.write(', size: Size(${info.width}, ${info.height})');
    }
    if (asset.flavors.isNotEmpty) {
      buffer.write(', flavors: {');
      final flavors = asset.flavors.map((e) => '\'$e\'').join(', ');
      buffer.write(flavors);
      buffer.write('}');
      buffer.write(','); // Better formatting.
    }
    buffer.write(')');
    return buffer.toString();
  }

  ImageMetadata? _getMetadata(AssetType asset) {
    try {
      // The SVG file is read fully, then parsed with the vector_graphics
      // library. This is quite a heavy way to extract just the dimensions,
      // but it's also the same way it will be eventually rendered by Flutter.
      final svg = File(asset.fullPath).readAsStringSync();
      final vec = parseWithoutOptimizers(svg);
      return ImageMetadata(vec.width, vec.height);
    } catch (e) {
      stderr.writeln(
        '[WARNING] Failed to parse SVG \'${asset.path}\' metadata: $e',
      );
      return null;
    }
  }

  @override
  bool isSupport(AssetType asset) =>
      asset.mime == 'image/svg+xml' || asset.extension == '.vec';

  @override
  bool get isConstConstructor => true;
}
