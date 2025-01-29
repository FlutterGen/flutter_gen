import 'dart:async';

import 'package:flutter_gen_core/settings/asset_type.dart';
import 'package:flutter_gen_core/settings/import.dart';

export 'package:flutter_gen_core/settings/asset_type.dart';
export 'package:flutter_gen_core/settings/import.dart';

/// A base class for all integrations. An integration is a class that
/// generates code for a specific asset type.
abstract class Integration {
  Integration(this.packageName, {this.parseMetadata = false});

  /// The package name for this asset. If empty, the asset is not in a package.
  final String packageName;
  late final bool isPackage = packageName.isNotEmpty;

  bool isEnabled = false;

  final bool parseMetadata;

  List<Import> get requiredImports;

  String get classOutput;

  String get className;

  /// Is this asset type supported by this integration?
  FutureOr<bool> isSupport(AssetType asset);

  bool get isConstConstructor;

  String classInstantiate(AssetType asset) {
    final buffer = StringBuffer(className);
    buffer.write('(');
    buffer.write('\'${asset.posixStylePath}\'');
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
}

/// The deprecation message for the package argument
/// if the asset is a library asset.
const String deprecationMessagePackage =
    "@Deprecated('Do not specify package for a generated library asset')";

/// Useful metadata about the parsed asset file when [parseMetadata] is true.
/// Currently only contains the width and height, but could contain more in
/// future.
class ImageMetadata {
  const ImageMetadata(this.width, this.height);

  final double width;
  final double height;
}
