import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';

class RiveIntegration extends Integration {
  RiveIntegration(String packageParameterLiteral)
      : super(packageParameterLiteral);

  String? get packageExpression => packageParameterLiteral.isNotEmpty
      ? 'packages/$packageParameterLiteral/'
      : null;

  @override
  List<String> get requiredImports => [
        'package:rive/rive.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class RiveGenImage {
  const RiveGenImage(this._assetName);

  final String _assetName;

  RiveAnimation rive({
    String? artboard,
    List<String> animations = const [],
    List<String> stateMachines = const [],
    BoxFit? fit,
    Alignment? alignment,
    Widget? placeHolder,
    bool antialiasing = true,
    List<RiveAnimationController> controllers = const [],
    OnInitCallback? onInit,
  }) {
    return RiveAnimation.asset(
      ${packageExpression == null ? '_assetName' : '\'$packageExpression\$_assetName\''},
      artboard: artboard,
      animations: animations,
      stateMachines: stateMachines,
      fit: fit,
      alignment: alignment,
      placeHolder: placeHolder,
      antialiasing: antialiasing,
      controllers: controllers,
      onInit: onInit,
    );
  }

  String get path => _assetName;

  String get keyName => ${packageExpression == null ? '_assetName' : '\'$packageExpression\$_assetName\''};
}''';

  @override
  String get className => 'RiveGenImage';

  @override
  String classInstantiate(String path) => 'RiveGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) => type.extension == '.riv';

  @override
  bool get isConstConstructor => true;
}
