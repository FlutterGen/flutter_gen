import 'package:flutter_gen/generator/camel_case.dart';
import 'package:yaml/yaml.dart';

class FontsGenerator {
  static generate(YamlList fontsList) {
    if (fontsList == null) return;

    final buffer = StringBuffer();
    buffer.writeln('/// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('/// *****************************************************');
    buffer.writeln('///  FlutterGen');
    buffer.writeln('/// *****************************************************');
    buffer.writeln();
    buffer.writeln('class FontFamily {');
    buffer.writeln('  FontFamily._();');

    fontsList.map((element) => element["family"] as String).forEach((family) {
      buffer.writeln(
          "  static const String ${CamelCase.from(family)} = \"$family\";");
    });

    buffer.writeln('}');
    return buffer.toString();
  }
}
