import 'package:flutter_gen_core/settings/asset_type.dart';

/// A base class for all integrations. An integration is a class that
/// generates code for a specific asset type.
abstract class Integration {
  Integration(this.packageName);

  /// The package name for this asset. If empty, the asset is not in a package.
  final String packageName;
  late final bool isPackage = packageName.isNotEmpty;

  bool isEnabled = false;

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
