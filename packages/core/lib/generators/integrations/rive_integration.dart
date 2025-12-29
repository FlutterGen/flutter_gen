import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:pub_semver/pub_semver.dart' show Version, VersionConstraint;

typedef RiveIntegrationLatest = RiveIntegration0140;

/// Create Rive integration based on the resolved version.
abstract final class RiveIntegration extends Integration {
  factory RiveIntegration(
    String packageName, {
    Version? resolvedVersion,
    VersionConstraint? resolvedVersionConstraint,
  }) {
    // Resolve integration by version.
    RiveIntegration? integration = switch (resolvedVersion) {
      final v? when v < Version(0, 14, 0) =>
        RiveIntegrationClassic(packageName),
      Version() => RiveIntegrationLatest(packageName),
      null => null,
    };

    // Resolve integration by version constraint.
    integration ??= switch (resolvedVersionConstraint) {
      final c? when c.allows(Version(0, 14, 0)) =>
        RiveIntegrationLatest(packageName),
      VersionConstraint() => RiveIntegrationClassic(packageName),
      null => null,
    };

    // Use the latest integration as the fallback.
    integration ??= RiveIntegrationLatest(packageName);

    return integration;
  }

  RiveIntegration._(String packageName) : super(packageName);
}

/// Rive integration for versions before 0.14.0.
final class RiveIntegrationClassic extends RiveIntegration {
  RiveIntegrationClassic(String packageName) : super._(packageName);

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

/// Rive integration for versions equal to or above 0.14.0.
final class RiveIntegration0140 extends RiveIntegrationClassic {
  RiveIntegration0140(String packageName) : super(packageName);

  @override
  String get _classDefinition => '''class RiveGenImage {
  const RiveGenImage(
    this._assetName, {
    this.flavors = const {},
  });

  final String _assetName;
  final Set<String> flavors;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  _rive.FileLoader riveFileLoader({
    _rive.Factory? factory,
  }) {
    return _rive.FileLoader.fromAsset(
      ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'},
      riveFactory: factory ?? _rive.Factory.rive,
    );
  }

  String get path => _assetName;

  String get keyName => ${isPackage ? '\'$packageExpression\$_assetName\'' : '_assetName'};
}''';
}
