import 'package:flutter_gen_core/settings/asset_type.dart';

abstract class Integration {
  Integration(this.packageParameterLiteral);

  final String packageParameterLiteral;

  bool isEnabled = false;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  bool isSupport(AssetType type);

  bool get isConstConstructor;
}
