import '../../settings/asset_type.dart';
import 'integration.dart';

class FlareIntegration extends Integration {
  // TODO: Until null safety generalizes
  // ignore: avoid_positional_boolean_parameters
  FlareIntegration({bool nullSafety = true}) : super(nullSafety: nullSafety);

  @override
  List<String> get requiredImports => [
        'package:flare_flutter/flare_actor.dart',
        'package:flare_flutter/flare_controller.dart',
      ];

  @override
  String get classOutput =>
      // TODO: Until null safety generalizes
      nullSafety ? _classDefinition : _classDefinitionWithNoNullSafety;

  /// Null Safety
  final String _classDefinition = '''class FlareGenImage {
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
      _assetName,
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
}''';

  /// No Null Safety
  /// TODO: Until null safety generalizes
  final String _classDefinitionWithNoNullSafety = '''class FlareGenImage {
  const FlareGenImage(this._assetName);

  final String _assetName;

  FlareActor flare({
    String boundsNode,
    String animation,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool isPaused = false,
    bool snapToEnd = false,
    FlareController controller,
    FlareCompletedCallback callback,
    Color color,
    bool shouldClip = true,
    bool sizeFromArtboard = false,
    String artboard,
    bool antialias = true,
  }) {
    return FlareActor(
      _assetName,
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
}''';

  @override
  String get className => 'FlareGenImage';

  @override
  String classInstantiate(String path) => 'FlareGenImage\(\'$path\'\)';

  @override
  bool isSupport(AssetType type) => type.extension == '.flr';

  @override
  bool get isConstConstructor => true;
}
