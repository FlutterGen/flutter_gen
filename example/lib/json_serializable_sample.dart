import 'package:json_annotation/json_annotation.dart';

part 'json_serializable_sample.g.dart';

@JsonSerializable()
class Person {
  final String firstName, lastName;
  final DateTime? dateOfBirth;

  Person({required this.firstName, required this.lastName, this.dateOfBirth});
  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
