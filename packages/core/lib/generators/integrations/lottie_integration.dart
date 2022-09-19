import 'package:flutter_gen_core/utils/version.dart';

import '../../settings/asset_type.dart';
import 'integration.dart';
import 'dart:convert';
import 'dart:io';

class LottieIntegration extends Integration {
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

  // Semver regular expression
  // https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
  final semVer = RegExp(
      r'^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
      multiLine: true);

  @override
  List<String> get requiredImports => [
        'package:lottie/lottie.dart',
      ];

  @override
  String get classOutput => _classDefinition;

  final String _classDefinition = '''class LottieGenImage {
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
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
  }) {
    return Lottie.asset(
      _assetName,
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
    try {
      if (type.extension != '.json') {
        return false;
      }
      String input = File(type.absolutePath).readAsStringSync();
      final fileKeys = jsonDecode(input) as Map<String, dynamic>;
      if (lottieKeys.every((key) => fileKeys.containsKey(key)) &&
          fileKeys['v'] != null &&
          semVer.hasMatch(fileKeys['v'])) {
        var version = semVer.firstMatch(fileKeys['v'].replaceAll(' ', ''))!;

        int major = int.parse(version.namedGroup('major')!);
        int minor = int.parse(version.namedGroup('minor')!);
        int patch = int.parse(version.namedGroup('patch')!);
        // Lottie version 4.4.0 is the first version that supports BodyMovin.
        // https://github.com/xvrh/lottie-flutter/blob/0e7499d82ea1370b6acf023af570395bbb59b42f/lib/src/parser/lottie_composition_parser.dart#L60
        return isAtLeastVersion(major, minor, patch, 4, 4, 0);
      }
    } on FormatException catch (e) {
      // Catches bad/corrupted json and reports it to user.
      stderr.writeln(e.message);
    }
    return false;
  }
}
