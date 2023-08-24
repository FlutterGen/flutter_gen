// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strings_yaml.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StringsYaml _$StringsYamlFromJson(Map json) => $checkedCreate(
      'StringsYaml',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['strings'],
        );
        final val = StringsYaml(
          $checkedConvert('strings', (v) => Map<String, String>.from(v as Map)),
        );
        return val;
      },
    );
