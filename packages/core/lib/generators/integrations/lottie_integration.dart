import 'dart:convert';
import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

class LottieIntegration extends Integration {
  LottieIntegration(String packageName) : super(packageName);

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

  String get packageExpression => isPackage ? ' = package' : '';

  @override
  List<Import> get requiredImports => [
        Import('package:flutter/widgets.dart'),
        Import('package:lottie/lottie.dart', alias: '_lottie'),
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class LottieGenImage {
  const LottieGenImage(
    this._assetName, {
    this.flavors = const {},
  });

  final String _assetName;
  final Set<String> flavors;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(
      BuildContext,
      Widget,
      _lottie.LottieComposition?,
    )? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    ${isPackage ? deprecationMessagePackage : ''}
    String? package$packageExpression,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
  }) {
    return _lottie.Lottie.asset(
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

  String get keyName => ${isPackage ? '\'packages/$packageName/\$_assetName\'' : '_assetName'};
}''';

  @override
  String get className => 'LottieGenImage';

  @override
  bool isSupport(AssetType asset) => isLottieFile(asset);

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
