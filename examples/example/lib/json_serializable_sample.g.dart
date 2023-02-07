// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable_sample.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map json) => $checkedCreate(
      'Person',
      json,
      ($checkedConvert) {
        final val = Person(
          firstName: $checkedConvert('firstName', (v) => v as String),
          lastName: $checkedConvert('lastName', (v) => v as String),
          dateOfBirth: $checkedConvert('dateOfBirth',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );
