// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pubspec _$PubspecFromJson(Map json) {
  return $checkedNew('Pubspec', json, () {
    $checkKeys(json, requiredKeys: const ['flutter_gen', 'flutter']);
    final val = Pubspec(
      flutterGen: $checkedConvert(json, 'flutter_gen',
          (v) => v == null ? null : FlutterGen.fromJson(v as Map)),
      flutter: $checkedConvert(json, 'flutter',
          (v) => v == null ? null : Flutter.fromJson(v as Map)),
    );
    return val;
  }, fieldKeyMap: const {'flutterGen': 'flutter_gen'});
}

Map<String, dynamic> _$PubspecToJson(Pubspec instance) => <String, dynamic>{
      'flutter_gen': instance.flutterGen,
      'flutter': instance.flutter,
    };

Flutter _$FlutterFromJson(Map json) {
  return $checkedNew('Flutter', json, () {
    $checkKeys(json, requiredKeys: const ['assets', 'fonts']);
    final val = Flutter(
      assets: $checkedConvert(json, 'assets',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
      fonts: $checkedConvert(
          json,
          'fonts',
          (v) => (v as List)
              ?.map((e) => e == null ? null : FlutterFonts.fromJson(e as Map))
              ?.toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$FlutterToJson(Flutter instance) => <String, dynamic>{
      'assets': instance.assets,
      'fonts': instance.fonts,
    };

FlutterFonts _$FlutterFontsFromJson(Map json) {
  return $checkedNew('FlutterFonts', json, () {
    $checkKeys(json, requiredKeys: const ['family']);
    final val = FlutterFonts(
      family: $checkedConvert(json, 'family', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$FlutterFontsToJson(FlutterFonts instance) =>
    <String, dynamic>{
      'family': instance.family,
    };

FlutterGen _$FlutterGenFromJson(Map json) {
  return $checkedNew('FlutterGen', json, () {
    $checkKeys(json, requiredKeys: const [
      'output',
      'line_length',
      'lineLength',
      'assets',
      'integrations',
      'colors'
    ]);
    final val = FlutterGen(
      output: $checkedConvert(json, 'output', (v) => v as String),
      lineLength: $checkedConvert(json, 'line_length', (v) => v as int),
      deprecatedLineLength:
          $checkedConvert(json, 'lineLength', (v) => v as int),
      assets: $checkedConvert(json, 'assets',
          (v) => v == null ? null : FlutterGenAssets.fromJson(v as Map)),
      integrations: $checkedConvert(json, 'integrations',
          (v) => v == null ? null : FlutterGenIntegrations.fromJson(v as Map)),
      colors: $checkedConvert(json, 'colors',
          (v) => v == null ? null : FlutterGenColors.fromJson(v as Map)),
    );
    return val;
  }, fieldKeyMap: const {
    'lineLength': 'line_length',
    'deprecatedLineLength': 'lineLength'
  });
}

Map<String, dynamic> _$FlutterGenToJson(FlutterGen instance) =>
    <String, dynamic>{
      'output': instance.output,
      'line_length': instance.lineLength,
      'lineLength': instance.deprecatedLineLength,
      'assets': instance.assets,
      'integrations': instance.integrations,
      'colors': instance.colors,
    };

FlutterGenColors _$FlutterGenColorsFromJson(Map json) {
  return $checkedNew('FlutterGenColors', json, () {
    $checkKeys(json, requiredKeys: const ['inputs']);
    final val = FlutterGenColors(
      inputs: $checkedConvert(json, 'inputs',
          (v) => (v as List)?.map((e) => e as String)?.toList()),
    );
    return val;
  });
}

Map<String, dynamic> _$FlutterGenColorsToJson(FlutterGenColors instance) =>
    <String, dynamic>{
      'inputs': instance.inputs,
    };

FlutterGenAssets _$FlutterGenAssetsFromJson(Map json) {
  return $checkedNew('FlutterGenAssets', json, () {
    $checkKeys(json, requiredKeys: const ['style']);
    final val = FlutterGenAssets(
      style: $checkedConvert(json, 'style', (v) => v as String),
    );
    return val;
  });
}

Map<String, dynamic> _$FlutterGenAssetsToJson(FlutterGenAssets instance) =>
    <String, dynamic>{
      'style': instance.style,
    };

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

Map<String, dynamic> _$FlutterGenIntegrationsToJson(
        FlutterGenIntegrations instance) =>
    <String, dynamic>{
      'flutter_svg': instance.flutterSvg,
      'flare_flutter': instance.flareFlutter,
    };
