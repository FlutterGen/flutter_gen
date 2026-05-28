import 'dart:io';

import 'package:flutter_gen_core/generators/integrations/integration.dart';
import 'package:flutter_gen_core/utils/log.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

class SvgIntegration extends Integration {
  SvgIntegration(
    String packageName, {
    super.parseMetadata,
  }) : super(packageName);

  String get packageExpression => isPackage ? ' = package' : '';

  @override
  List<Import> get requiredImports => [
        const Import(
            'package:flutter_gen_interface/flutter_gen_interface.dart'),
      ];

  @override
  String get classOutput => '';

  @override
  String get className => 'SvgGenImage';

  static const vectorCompileTransformer = 'vector_graphics_compiler';

  @override
  String classInstantiate(AssetType asset) {
    // Query extra information about the SVG.
    final info = parseMetadata ? _getMetadata(asset) : null;
    final buffer = StringBuffer(className);
    if (asset.extension == '.vec' ||
        asset.transformers.contains(vectorCompileTransformer)) {
      buffer.write('.vec');
    }
    buffer.write('(');
    buffer.write('\'${asset.posixStylePath}\'');
    if (info != null) {
      buffer.write(', size: Size(${info.width}, ${info.height})');
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

  ImageMetadata? _getMetadata(AssetType asset) {
    try {
      // The SVG file is read fully, then parsed with the vector_graphics
      // library. This is quite a heavy way to extract just the dimensions,
      // but it's also the same way it will be eventually rendered by Flutter.
      final svg = File(asset.fullPath).readAsStringSync();
      final vec = parseWithoutOptimizers(svg);
      return ImageMetadata(
        width: vec.width,
        height: vec.height,
      );
    } catch (e, s) {
      log.warning('Failed to parse SVG \'${asset.path}\' metadata.', e, s);
      return null;
    }
  }

  @override
  bool isSupport(AssetType asset) =>
      asset.mime == 'image/svg+xml' || asset.extension == '.vec';

  @override
  bool get isConstConstructor => true;
}
