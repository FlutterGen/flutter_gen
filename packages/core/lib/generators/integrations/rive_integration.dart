import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';

class RiveIntegration extends Integration {
  RiveIntegration(String packageName) : super(packageName);

  String? get packageExpression => isPackage ? 'packages/$packageName/' : null;

  @override
  List<String> get requiredImports => [
        'package:flutter/widgets.dart',
        'package:rive/rive.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class RiveGenImage {
  const RiveGenImage(
    this._assetName, {
    this.flavors = const {},
  });

  final String _assetName;
  final Set<String> flavors;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  RiveAnimation rive({
    String? artboard,
    List<String> animations = const [],
    List<String> stateMachines = const [],
    BoxFit? fit,
    Alignment? alignment,
    Widget? placeHolder,
    bool antialiasing = true,
    bool useArtboardSize = false,
    List<RiveAnimationController> controllers = const [],
    OnInitCallback? onInit,
  }) {
    return RiveAnimation.asset(
      ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'},
      artboard: artboard,
      animations: animations,
      stateMachines: stateMachines,
      fit: fit,
      alignment: alignment,
      placeHolder: placeHolder,
      antialiasing: antialiasing,
      useArtboardSize: useArtboardSize,
      controllers: controllers,
      onInit: onInit,
    );
  }

  String get path => _assetName;

  String get keyName => ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'};
}''';

  @override
  String get className => 'RiveGenImage';

  @override
  bool isSupport(AssetType asset) => asset.extension == '.riv';

  @override
  bool get isConstConstructor => true;
}
