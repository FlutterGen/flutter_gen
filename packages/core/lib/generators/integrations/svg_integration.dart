import '../../settings/asset_type.dart';
import 'integration.dart';

class SvgIntegration extends Integration {
  SvgIntegration(this._packageParameterLiteral);

  final String _packageParameterLiteral;

  String get packageExpression => _packageParameterLiteral.isNotEmpty
      ? ' = \'$_packageParameterLiteral\''
      : '';

  @override
  List<String> get requiredImports => [
        'package:flutter_svg/flutter_svg.dart',
        'package:flutter/services.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class SvgGenImage {
  const SvgGenImage(this._assetName);

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
    Color? color,
    BlendMode colorBlendMode = BlendMode.srcIn,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    Clip clipBehavior = Clip.hardEdge,
    bool cacheColorFilter = false,
    SvgTheme? theme,
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
      color: color,
      colorBlendMode: colorBlendMode,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
      theme: theme,
    );
  }

  String get path => _assetName;
}''';

  @override
  String get className => 'SvgGenImage';

  @override
  String classInstantiate(String path) => 'SvgGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) => type.mime == 'image/svg+xml';

  @override
  bool get isConstConstructor => true;
}
