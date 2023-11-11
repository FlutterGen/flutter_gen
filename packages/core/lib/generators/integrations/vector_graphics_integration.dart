import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/generators/integrations/svg_integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';

/// An implementation of [Integration] for `flutter_svg` and `vector_graphics`.
///
/// This integration depends on [SvgIntegration].
class VectorGraphicsIntegration extends Integration {
  VectorGraphicsIntegration(
    String packageParameterLiteral,
    this._svgIntegration,
  ) : super(packageParameterLiteral);

  final SvgIntegration _svgIntegration;

  String get packageExpression => packageParameterLiteral.isNotEmpty
      ? ' = \'$packageParameterLiteral\''
      : '';

  @override
  set isEnabled(bool value) {
    super.isEnabled = value;
    if (value && !_svgIntegration.isEnabled) {
      _svgIntegration.isEnabled = true;
    }
  }

  @override
  List<String> get requiredImports => [
        'package:flutter_svg/flutter_svg.dart',
        'package:vector_graphics/vector_graphics.dart',
        'package:flutter/services.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition =>
      '''class SvgVecGenImage implements SvgGenImage {
  const SvgVecGenImage(this._assetName);

  final String _assetName;

  @override
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
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture(
      AssetBytesLoader(_assetName, packageName: package, assetBundle: bundle),
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
      colorFilter: colorFilter,
      clipBehavior: clipBehavior,
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
