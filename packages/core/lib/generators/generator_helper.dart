import 'package:flutter_gen_core/settings/import.dart';

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

String import(Import package) {
  return 'import \'${package.import}\''
      '${package.alias != null ? ' as ${package.alias}' : ''};';
}
