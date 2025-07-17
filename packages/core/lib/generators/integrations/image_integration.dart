import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:image/image.dart' as img;
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

/// The main image integration, supporting all image asset types. See
/// [isSupport] for the exact supported mime types.
///
/// This integration is by enabled by default.
class ImageIntegration extends Integration {
  ImageIntegration(
    String packageName, {
    required super.parseMetadata,
    required this.parseAnimation,
  }) : super(packageName);

  final bool parseAnimation;

  String get packageParameter => isPackage ? ' = package' : '';

  String get keyName =>
      isPackage ? "'packages/$packageName/\$_assetName'" : '_assetName';

  @override
  List<Import> get requiredImports => const [
        Import('package:flutter/widgets.dart'),
      ];

  @override
  String get classOutput => _classDefinition;

  String get _classDefinition => '''class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

${isPackage ? "\n  static const String package = '$packageName';" : ''}

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    ${isPackage ? '$deprecationMessagePackage\n' : ''}String? package$packageParameter,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    ${isPackage ? '$deprecationMessagePackage\n' : ''}String? package$packageParameter,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => $keyName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
''';

  @override
  String get className => 'AssetGenImage';

  @override
  String classInstantiate(AssetType asset) {
    final info = parseMetadata || parseAnimation ? _getMetadata(asset) : null;
    final buffer = StringBuffer(className);
    buffer.write('(');
    buffer.write('\'${asset.posixStylePath}\'');
    if (info != null) {
      buffer.write(', size: const Size(${info.width}, ${info.height})');

      if (info.animation case final animation?) {
        buffer.write(', animation: const AssetGenImageAnimation(');
        buffer.write('isAnimation: ${animation.frames > 1}');
        buffer.write(
          ', duration: Duration(milliseconds: ${animation.duration.inMilliseconds})',
        );
        buffer.write(', frames: ${animation.frames}');
        buffer.write(')');
      }
    }
    if (asset.flavors.isNotEmpty) {
      buffer.write(', flavors: {');
      final flavors = asset.flavors.map((e) => '\'$e\'').join(', ');
      buffer.write(flavors);
      buffer.write('}');
      buffer.write(','); // Better formatting.
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool isSupport(AssetType asset) {
    /// Flutter official supported image types. See
    /// https://api.flutter.dev/flutter/widgets/Image-class.html
    switch (asset.mime) {
      case 'image/jpeg':
      case 'image/png':
      case 'image/gif':
      case 'image/bmp':
      case 'image/vnd.wap.wbmp':
      case 'image/webp':
        return true;
      default:
        return false;
    }
  }

  @override
  bool get isConstConstructor => true;

  /// Extract metadata from the asset.
  ImageMetadata? _getMetadata(AssetType asset) {
    try {
      final result = ImageSizeGetter.getSizeResult(
        FileInput(File(asset.fullPath)),
      );
      final size = result.size;
      final animation = parseAnimation ? _parseAnimation(asset) : null;

      return ImageMetadata(
        width: size.width.toDouble(),
        height: size.height.toDouble(),
        animation: animation,
      );
    } catch (e, s) {
      log.warning('Failed to parse \'${asset.path}\' metadata.', e, s);
    }
    return null;
  }

  ImageAnimation? _parseAnimation(AssetType asset) {
    try {
      final decoder = switch (asset.mime) {
        'image/gif' => img.GifDecoder(),
        'image/webp' => img.WebPDecoder(),
        _ => null,
      };

      if (decoder == null) {
        return null;
      }

      final file = File(asset.fullPath);
      final bytes = file.readAsBytesSync();
      final image = decoder.decode(bytes);

      if (image == null) {
        return null;
      }

      return ImageAnimation(
        frames: image.frames.length,
        duration: Duration(
          milliseconds: image.frames.fold(
            0,
            (duration, frame) => duration + frame.frameDuration,
          ),
        ),
      );
    } catch (e) {
      stderr.writeln(
        '[WARNING] Failed to parse \'${asset.path}\' animation information: $e',
      );
    }
    return null;
  }
}
