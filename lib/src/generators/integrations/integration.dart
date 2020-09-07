abstract class Integration {
  bool isEnabled = false;

  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  String get mime;

  bool get isConstConstructor;
}
