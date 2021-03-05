import '../../settings/asset_type.dart';

abstract class Integration {
  // TODO: Until null safety generalizes
  // ignore: avoid_positional_boolean_parameters
  Integration({required this.disabledNullSafety});

  bool isEnabled = false;

  // TODO: Until null safety generalizes
  bool disabledNullSafety = false;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  bool isSupport(AssetType type);

  bool get isConstConstructor;
}
