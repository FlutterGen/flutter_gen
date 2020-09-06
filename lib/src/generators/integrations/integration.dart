abstract class Integration {
  List<String> get requiredImports;

  String get classOutput;

  String get className;

  String classInstantiate(String path);

  String get mime;

  bool get isConstConstructor;
}
