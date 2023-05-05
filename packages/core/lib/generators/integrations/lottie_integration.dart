import 'dart:convert';
import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

class LottieIntegration extends Integration {
  LottieIntegration(String packageParameterLiteral)
      : super(packageParameterLiteral);

  // These are required keys for this integration.
  static const lottieKeys = [
    'w', // width
    'h', // height
    'ip', // The frame at which the Lottie animation starts at
    'op', // The frame at which the Lottie animation ends at
    'fr', // frame rate
    'v', // // Must include version
    'layers', // Must include layers
  ];

  String get packageExpression => packageParameterLiteral.isNotEmpty
      ? ' = \'$packageParameterLiteral\''
      : '';

  @override
  List<String> get requiredImports => [
        'package:lottie/lottie.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class LottieGenImage {
  const LottieGenImage(this._assetName);

  final String _assetName;

  LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    LottieDelegates? delegates,
    LottieOptions? options,
    void Function(LottieComposition)? onLoaded,
    LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, LottieComposition?)? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package$packageExpression,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
  }) {
    return Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
    );
  }

  String get path => _assetName;

  String get keyName => ${packageParameterLiteral.isEmpty ? '_assetName' : '\'packages/$packageParameterLiteral/\$_assetName\''};
}''';

  @override
  String get className => 'LottieGenImage';

  @override
  String classInstantiate(String path) => 'LottieGenImage(\'$path\')';

  @override
  bool isSupport(AssetType type) => isLottieFile(type);

  @override
  bool get isConstConstructor => true;

  bool isLottieFile(AssetType type) {
    if (type.mime != 'application/json') {
      return false;
    }
    try {
      final absolutePath = p.join(type.rootPath, type.path);
      String input = File(absolutePath).readAsStringSync();
      final fileKeys = jsonDecode(input) as Map<String, dynamic>;
      if (lottieKeys.every(fileKeys.containsKey) && fileKeys['v'] != null) {
        var version = Version.parse(fileKeys['v']);
        // Lottie version 4.4.0 is the first version that supports BodyMovin.
        // https://github.com/xvrh/lottie-flutter/blob/0e7499d82ea1370b6acf023af570395bbb59b42f/lib/src/parser/lottie_composition_parser.dart#L60
        return version >= Version(4, 4, 0);
      }
    } on FormatException catch (_) {
      // Catches bad/corrupted json and reports it to user.
      // stderr.writeln(e.message);
      // no-op
    } on TypeError catch (_) {
      // Catches bad/corrupted json and reports it to user.
      // stderr.writeln(e);
      // no-op
    }
    return false;
  }
}
