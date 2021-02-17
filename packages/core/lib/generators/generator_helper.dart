String get header {
  return '''/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

''';
}

String import(String package) => 'import \'$package\';';

// Replace to Posix style for Windows separator.
String posixStyle(String path) => path.replaceAll(r'\', r'/');
