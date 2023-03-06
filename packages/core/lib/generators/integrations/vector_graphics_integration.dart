import '../../settings/asset_type.dart';
import 'integration.dart';

class VectorGraphicsIntegration extends Integration {
  VectorGraphicsIntegration(String packageParameterLiteral)
      : super(packageParameterLiteral);

  String get packageExpression => packageParameterLiteral.isNotEmpty
      ? ' = \'$packageParameterLiteral\''
      : '';

  @override
  List<String> get requiredImports => [
        'package:flutter_svg/flutter_svg.dart',
        'package:vector_graphics/vector_graphics.dart',
        'package:flutter/services.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class SvgVecGenImage {
  const SvgVecGenImage(this._assetName);

  final String _assetName;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
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
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated Clip? clipBehavior,
    @deprecated bool cacheColorFilter = false,
  }) {
    return SvgPicture(
      AssetBytesLoader(_assetName),
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

  String get keyName => ${packageParameterLiteral.isEmpty ? '_assetName' : '\'packages/$packageParameterLiteral/\$_assetName\''};
}''';

  @override
  String get className => 'SvgVecGenImage';

  @override
  String classInstantiate(String path) => 'SvgVecGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) => type.path.toLowerCase().endsWith('.vec');

  @override
  bool get isConstConstructor => true;
}
