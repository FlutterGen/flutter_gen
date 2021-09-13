import '../../settings/asset_type.dart';

abstract class Integration {
  bool isEnabled = false;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  bool isSupport(AssetType type);

  bool get isConstConstructor;
}
