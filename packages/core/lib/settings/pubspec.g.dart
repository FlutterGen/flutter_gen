// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pubspec _$PubspecFromJson(Map json) => $checkedCreate(
      'Pubspec',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['name', 'flutter_gen', 'flutter'],
        );
        final val = Pubspec(
          packageName: $checkedConvert('name', (v) => v as String),
          flutterGen: $checkedConvert(
              'flutter_gen', (v) => FlutterGen.fromJson(v as Map)),
          flutter:
              $checkedConvert('flutter', (v) => Flutter.fromJson(v as Map)),
        );
        return val;
      },
      fieldKeyMap: const {'packageName': 'name', 'flutterGen': 'flutter_gen'},
    );

Flutter _$FlutterFromJson(Map json) => $checkedCreate(
      'Flutter',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['assets', 'fonts'],
        );
        final val = Flutter(
          assets: $checkedConvert('assets',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          fonts: $checkedConvert(
              'fonts',
              (v) => (v as List<dynamic>)
                  .map((e) => FlutterFonts.fromJson(e as Map))
                  .toList()),
        );
        return val;
      },
    );

FlutterFonts _$FlutterFontsFromJson(Map json) => $checkedCreate(
      'FlutterFonts',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['family'],
        );
        final val = FlutterFonts(
          family: $checkedConvert('family', (v) => v as String),
        );
        return val;
      },
    );

FlutterGen _$FlutterGenFromJson(Map json) => $checkedCreate(
      'FlutterGen',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'output',
            'line_length',
            'assets',
            'fonts',
            'integrations',
            'colors'
          ],
        );
        final val = FlutterGen(
          output: $checkedConvert('output', (v) => v as String),
          lineLength: $checkedConvert('line_length', (v) => v as int),
          assets: $checkedConvert(
              'assets', (v) => FlutterGenAssets.fromJson(v as Map)),
          fonts: $checkedConvert(
              'fonts', (v) => FlutterGenFonts.fromJson(v as Map)),
          integrations: $checkedConvert(
              'integrations', (v) => FlutterGenIntegrations.fromJson(v as Map)),
          colors: $checkedConvert(
              'colors', (v) => FlutterGenColors.fromJson(v as Map)),
        );
        return val;
      },
      fieldKeyMap: const {'lineLength': 'line_length'},
    );

FlutterGenColors _$FlutterGenColorsFromJson(Map json) => $checkedCreate(
      'FlutterGenColors',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['enabled', 'inputs'],
        );
        final val = FlutterGenColors(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          inputs: $checkedConvert('inputs',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
    );

FlutterGenAssets _$FlutterGenAssetsFromJson(Map json) => $checkedCreate(
      'FlutterGenAssets',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'enabled',
            'package_parameter_enabled',
            'style',
            'exclude'
          ],
        );
        final val = FlutterGenAssets(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          packageParameterEnabled:
              $checkedConvert('package_parameter_enabled', (v) => v as bool),
          style: $checkedConvert('style', (v) => v as String),
          exclude: $checkedConvert('exclude',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
        );
        return val;
      },
      fieldKeyMap: const {
        'packageParameterEnabled': 'package_parameter_enabled'
      },
    );

FlutterGenFonts _$FlutterGenFontsFromJson(Map json) => $checkedCreate(
      'FlutterGenFonts',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['enabled'],
        );
        final val = FlutterGenFonts(
          enabled: $checkedConvert('enabled', (v) => v as bool),
        );
        return val;
      },
    );

FlutterGenIntegrations _$FlutterGenIntegrationsFromJson(Map json) =>
    $checkedCreate(
      'FlutterGenIntegrations',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['flutter_svg', 'flare_flutter', 'rive'],
        );
        final val = FlutterGenIntegrations(
          flutterSvg: $checkedConvert('flutter_svg', (v) => v as bool),
          flareFlutter: $checkedConvert('flare_flutter', (v) => v as bool),
          rive: $checkedConvert('rive', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {
        'flutterSvg': 'flutter_svg',
        'flareFlutter': 'flare_flutter'
      },
    );
