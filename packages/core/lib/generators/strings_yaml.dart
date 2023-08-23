
import 'package:json_annotation/json_annotation.dart';

part 'strings_yaml.g.dart';

@JsonSerializable()
class StringsYaml {

  StringsYaml(this.strings);

  @JsonKey(name: 'strings', required: true)
  final Map<String, String> strings;

  factory StringsYaml.fromJson(Map json) => _$StringsYamlFromJson(json);
}