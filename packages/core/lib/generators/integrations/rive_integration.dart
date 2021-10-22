import '../../settings/asset_type.dart';
import 'integration.dart';

class RiveIntegration extends Integration {
  @override
  List<String> get requiredImports => [
        'package:rive/rive.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  final String _classDefinition = '''class RiveGenImage {
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
      _assetName,
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
