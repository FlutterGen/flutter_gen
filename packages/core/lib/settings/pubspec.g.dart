// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pubspec _$PubspecFromJson(Map json) {
  return $checkedNew('Pubspec', json, () {
    $checkKeys(json, requiredKeys: const ['name', 'flutter_gen', 'flutter']);
    final val = Pubspec(
      packageName: $checkedConvert(json, 'name', (v) => v as String),
      flutterGen: $checkedConvert(
          json, 'flutter_gen', (v) => FlutterGen.fromJson(v as Map)),
      flutter:
          $checkedConvert(json, 'flutter', (v) => Flutter.fromJson(v as Map)),
    );
    return val;
  }, fieldKeyMap: const {'packageName': 'name', 'flutterGen': 'flutter_gen'});
}

Flutter _$FlutterFromJson(Map json) {
  return $checkedNew('Flutter', json, () {
    $checkKeys(json, requiredKeys: const ['assets', 'fonts']);
    final val = Flutter(
      assets: $checkedConvert(json, 'assets',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
      fonts: $checkedConvert(
          json,
          'fonts',
          (v) => (v as List<dynamic>)
              .map((e) => FlutterFonts.fromJson(e as Map))
              .toList()),
    );
    return val;
  });
}

FlutterFonts _$FlutterFontsFromJson(Map json) {
  return $checkedNew('FlutterFonts', json, () {
    $checkKeys(json, requiredKeys: const ['family']);
    final val = FlutterFonts(
      family: $checkedConvert(json, 'family', (v) => v as String),
    );
    return val;
  });
}

FlutterGen _$FlutterGenFromJson(Map json) {
  return $checkedNew('FlutterGen', json, () {
    $checkKeys(json, requiredKeys: const [
      'output',
      'line_length',
      'lineLength',
      'null_safety',
      'assets',
      'fonts',
      'integrations',
      'colors'
    ]);
    final val = FlutterGen(
      output: $checkedConvert(json, 'output', (v) => v as String),
      lineLength1: $checkedConvert(json, 'line_length', (v) => v as int),
      lineLength0: $checkedConvert(json, 'lineLength', (v) => v as int),
      nullSafety: $checkedConvert(json, 'null_safety', (v) => v as bool),
      assets: $checkedConvert(
          json, 'assets', (v) => FlutterGenAssets.fromJson(v as Map)),
      fonts: $checkedConvert(
          json, 'fonts', (v) => FlutterGenFonts.fromJson(v as Map)),
      integrations: $checkedConvert(json, 'integrations',
          (v) => FlutterGenIntegrations.fromJson(v as Map)),
      colors: $checkedConvert(
          json, 'colors', (v) => FlutterGenColors.fromJson(v as Map)),
    );
    return val;
  }, fieldKeyMap: const {
    'lineLength1': 'line_length',
    'lineLength0': 'lineLength',
    'nullSafety': 'null_safety'
  });
}

FlutterGenColors _$FlutterGenColorsFromJson(Map json) {
  return $checkedNew('FlutterGenColors', json, () {
    $checkKeys(json, requiredKeys: const ['enabled', 'inputs']);
    final val = FlutterGenColors(
      enabled: $checkedConvert(json, 'enabled', (v) => v as bool),
      inputs: $checkedConvert(json, 'inputs',
          (v) => (v as List<dynamic>).map((e) => e as String).toList()),
    );
    return val;
  });
}

FlutterGenAssets _$FlutterGenAssetsFromJson(Map json) {
  return $checkedNew('FlutterGenAssets', json, () {
    $checkKeys(json,
        requiredKeys: const ['enabled', 'package_parameter_enabled', 'style']);
    final val = FlutterGenAssets(
      enabled: $checkedConvert(json, 'enabled', (v) => v as bool),
      packageParameterEnabled:
          $checkedConvert(json, 'package_parameter_enabled', (v) => v as bool),
      style: $checkedConvert(json, 'style', (v) => v as String),
    );
    return val;
  }, fieldKeyMap: const {
    'packageParameterEnabled': 'package_parameter_enabled'
  });
}

FlutterGenFonts _$FlutterGenFontsFromJson(Map json) {
  return $checkedNew('FlutterGenFonts', json, () {
    $checkKeys(json, requiredKeys: const ['enabled']);
    final val = FlutterGenFonts(
      enabled: $checkedConvert(json, 'enabled', (v) => v as bool),
    );
    return val;
  });
}

FlutterGenIntegrations _$FlutterGenIntegrationsFromJson(Map json) {
  return $checkedNew('FlutterGenIntegrations', json, () {
    $checkKeys(json, requiredKeys: const ['flutter_svg', 'flare_flutter']);
    final val = FlutterGenIntegrations(
      flutterSvg: $checkedConvert(json, 'flutter_svg', (v) => v as bool),
      flareFlutter: $checkedConvert(json, 'flare_flutter', (v) => v as bool),
    );
    return val;
  }, fieldKeyMap: const {
    'flutterSvg': 'flutter_svg',
    'flareFlutter': 'flare_flutter'
  });
}
