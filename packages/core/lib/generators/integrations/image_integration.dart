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
  List<Import> get requiredImports => [
        const Import(
            'package:flutter_gen_interface/flutter_gen_interface.dart'),
      ];

  @override
  String get classOutput => '';

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
      if (!isPackage) buffer.write(','); // Better formatting.
    }
    if (isPackage) {
      buffer.write(', package: \'$packageName\',');
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
