import 'package:flutter_gen_core/generators/integrations/integration.dart';

class RiveIntegration extends Integration {
  RiveIntegration(String packageName) : super(packageName);

  String? get packageExpression => isPackage ? 'packages/$packageName/' : null;

  @override
  List<Import> get requiredImports => const [
        Import('package:flutter/widgets.dart'),
        Import('package:rive/rive.dart', alias: '_rive'),
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

  _rive.RiveAnimation rive({
    String? artboard,
    List<String> animations = const [],
    List<String> stateMachines = const [],
    BoxFit? fit,
    Alignment? alignment,
    Widget? placeHolder,
    bool antialiasing = true,
    bool useArtboardSize = false,
    List<_rive.RiveAnimationController> controllers = const [],
    _rive.OnInitCallback? onInit,
  }) {
    return _rive.RiveAnimation.asset(
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
