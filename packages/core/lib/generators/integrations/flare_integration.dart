import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';

class FlareIntegration extends Integration {
  FlareIntegration(String packageParameterLiteral)
      : super(packageParameterLiteral);

  String? get packageExpression => packageParameterLiteral.isNotEmpty
      ? 'packages/$packageParameterLiteral/'
      : null;

  @override
  List<String> get requiredImports => [
        'package:flare_flutter/flare_actor.dart',
        'package:flare_flutter/flare_controller.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class FlareGenImage {
  const FlareGenImage(this._assetName);

  final String _assetName;

  FlareActor flare({
    String? boundsNode,
    String? animation,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool isPaused = false,
    bool snapToEnd = false,
    FlareController? controller,
    FlareCompletedCallback? callback,
    Color? color,
    bool shouldClip = true,
    bool sizeFromArtboard = false,
    String? artboard,
    bool antialias = true,
  }) {
    return FlareActor(
      ${packageExpression == null ? '_assetName' : '\'$packageExpression\$_assetName\''},
      boundsNode: boundsNode,
      animation: animation,
      fit: fit,
      alignment: alignment,
      isPaused: isPaused,
      snapToEnd: snapToEnd,
      controller: controller,
      callback: callback,
      color: color,
      shouldClip: shouldClip,
      sizeFromArtboard: sizeFromArtboard,
      artboard: artboard,
      antialias: antialias,
    );
  }

  String get path => _assetName;

  String get keyName => ${packageExpression == null ? '_assetName' : '\'$packageExpression\$_assetName\''};
}''';

  @override
  String get className => 'FlareGenImage';

  @override
  String classInstantiate(String path) => 'FlareGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) => type.extension == '.flr';

  @override
  bool get isConstConstructor => true;
}
