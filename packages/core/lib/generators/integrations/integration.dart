import 'package:flutter_gen_core/settings/asset_type.dart';

/// A base class for all integrations. An integration is a class that
/// generates code for a specific asset type.
abstract class Integration {
  Integration(this.packageName, {this.parseMetadata = false});

  /// The package name for this asset. If empty, the asset is not in a package.
  final String packageName;
  late final bool isPackage = packageName.isNotEmpty;

  bool isEnabled = false;

  final bool parseMetadata;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(AssetType asset);

  /// Is this asset type supported by this integration?
  bool isSupport(AssetType asset);

  bool get isConstConstructor;
}

/// The deprecation message for the package argument
/// if the asset is a library asset.
const String deprecationMessagePackage =
    "@Deprecated('Do not specify package for a generated library asset')";

/// Useful metadata about the parsed asset file when [parseMetadata] is true.
/// Currently only contains the width and height, but could contain more in
/// future.
class ImageMetadata {
  final double width;
  final double height;

  ImageMetadata(this.width, this.height);
}
