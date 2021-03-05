String get header {
  return '''/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

''';
}

/// TODO: Until null safety generalizes
String get headerWithNoNullSafety {
  return '''// @dart = 2.10
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

''';
}

String import(String package) => 'import \'$package\';';

// Replace to Posix style for Windows separator.
String posixStyle(String path) => path.replaceAll(r'\', r'/');
