import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';

class FlareIntegration extends Integration {
  FlareIntegration(String packageName) : super(packageName);

  String? get packageExpression => isPackage ? 'packages/$packageName/' : null;

  @override
  List<Import> get requiredImports => [
        Import('package:flutter/widgets.dart'),
        Import(
          'package:flare_flutter/flare_actor.dart',
          alias: '_flare_actor',
        ),
        Import(
          'package:flare_flutter/flare_controller.dart',
          alias: '_flare_controller',
        ),
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class FlareGenImage {
  const FlareGenImage(
    this._assetName, {
    this.flavors = const {},
  });

  final String _assetName;
  final Set<String> flavors;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  _flare_actor.FlareActor flare({
    String? boundsNode,
    String? animation,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool isPaused = false,
    bool snapToEnd = false,
    _flare_controller.FlareController? controller,
    _flare_actor.FlareCompletedCallback? callback,
    Color? color,
    bool shouldClip = true,
    bool sizeFromArtboard = false,
    String? artboard,
    bool antialias = true,
  }) {
    return _flare_actor.FlareActor(
      ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'},
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

  String get keyName => ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'};
}''';

  @override
  String get className => 'FlareGenImage';

  @override
  bool isSupport(AssetType asset) {
    if (asset.extension == '.flr') {
      stdout.writeln(
        'Legacy Flare files are no longer supported for the generation.\n'
        'https://help.rive.app/getting-started/faq-1/importing-rive-1-files.',
      );
    }
    return false;
  }

  @override
  bool get isConstConstructor => true;
}
