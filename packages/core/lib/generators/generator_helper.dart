String get header {
  return '''/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

''';
}

String get ignore {
  return '''// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use
  
''';
}

String import(String package) => 'import \'$package\';';

// Replace to Posix style for Windows separator.
String posixStyle(String path) => path.replaceAll(r'\', r'/');
