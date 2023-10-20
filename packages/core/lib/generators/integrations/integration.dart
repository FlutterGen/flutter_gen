import 'package:flutter_gen_core/settings/asset_type.dart';

abstract class Integration {
  Integration(this.packageParameterLiteral);

  final String packageParameterLiteral;
  late final bool isPackage = packageParameterLiteral.isNotEmpty;

  bool isEnabled = false;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  bool isSupport(AssetType type);

  bool get isConstConstructor;
}

/// The deprecation message for the package argument
/// if the asset is a library asset.
const String deprecationMessagePackage =
    "@Deprecated('Do not specify package for a generated library asset')";
