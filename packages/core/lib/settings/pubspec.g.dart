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
              (v) => (v as List<dynamic>).map((e) => e as Object).toList()),
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
          allowedKeys: const [
            'output',
            'line_length',
            'parse_metadata',
            'assets',
            'fonts',
            'integrations',
            'colors'
          ],
          requiredKeys: const [
            'output',
            'line_length',
            'parse_metadata',
            'assets',
            'fonts',
            'integrations',
            'colors'
          ],
        );
        final val = FlutterGen(
          output: $checkedConvert('output', (v) => v as String),
          lineLength: $checkedConvert('line_length', (v) => (v as num).toInt()),
          parseMetadata: $checkedConvert('parse_metadata', (v) => v as bool),
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
      fieldKeyMap: const {
        'lineLength': 'line_length',
        'parseMetadata': 'parse_metadata'
      },
    );

FlutterGenColors _$FlutterGenColorsFromJson(Map json) => $checkedCreate(
      'FlutterGenColors',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['enabled', 'inputs', 'outputs'],
          requiredKeys: const ['enabled', 'inputs', 'outputs'],
        );
        final val = FlutterGenColors(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          inputs: $checkedConvert('inputs',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          outputs: $checkedConvert(
              'outputs', (v) => FlutterGenElementOutputs.fromJson(v as Map)),
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
          allowedKeys: const [
            'enabled',
            'package_parameter_enabled',
            'style',
            'outputs',
            'exclude'
          ],
          requiredKeys: const ['enabled', 'outputs', 'exclude'],
        );
        final val = FlutterGenAssets(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          packageParameterEnabled:
              $checkedConvert('package_parameter_enabled', (v) => v as bool?),
          style: $checkedConvert('style', (v) => v as String?),
          outputs: $checkedConvert('outputs',
              (v) => FlutterGenElementAssetsOutputs.fromJson(v as Map)),
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
          allowedKeys: const ['enabled', 'outputs'],
          requiredKeys: const ['enabled', 'outputs'],
        );
        final val = FlutterGenFonts(
          enabled: $checkedConvert('enabled', (v) => v as bool),
          outputs: $checkedConvert('outputs',
              (v) => FlutterGenElementFontsOutputs.fromJson(v as Map)),
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
          allowedKeys: const ['image', 'flutter_svg', 'rive', 'lottie'],
          requiredKeys: const ['image', 'flutter_svg', 'rive', 'lottie'],
        );
        final val = FlutterGenIntegrations(
          image: $checkedConvert('image', (v) => v as bool),
          flutterSvg: $checkedConvert('flutter_svg', (v) => v as bool),
          rive: $checkedConvert('rive', (v) => v as bool),
          lottie: $checkedConvert('lottie', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {'flutterSvg': 'flutter_svg'},
    );

FlutterGenElementOutputs _$FlutterGenElementOutputsFromJson(Map json) =>
    $checkedCreate(
      'FlutterGenElementOutputs',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['class_name'],
          requiredKeys: const ['class_name'],
        );
        final val = FlutterGenElementOutputs(
          className: $checkedConvert('class_name', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'className': 'class_name'},
    );

FlutterGenElementAssetsOutputs _$FlutterGenElementAssetsOutputsFromJson(
        Map json) =>
    $checkedCreate(
      'FlutterGenElementAssetsOutputs',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const [
            'class_name',
            'package_parameter_enabled',
            'directory_path_enabled',
            'style'
          ],
          requiredKeys: const ['class_name', 'style'],
        );
        final val = FlutterGenElementAssetsOutputs(
          className: $checkedConvert('class_name', (v) => v as String),
          packageParameterEnabled: $checkedConvert(
              'package_parameter_enabled', (v) => v as bool? ?? false),
          directoryPathEnabled: $checkedConvert(
              'directory_path_enabled', (v) => v as bool? ?? false),
          style: $checkedConvert('style',
              (v) => FlutterGenElementAssetsOutputsStyle.fromJson(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'className': 'class_name',
        'packageParameterEnabled': 'package_parameter_enabled',
        'directoryPathEnabled': 'directory_path_enabled'
      },
    );

FlutterGenElementFontsOutputs _$FlutterGenElementFontsOutputsFromJson(
        Map json) =>
    $checkedCreate(
      'FlutterGenElementFontsOutputs',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['class_name', 'package_parameter_enabled'],
          requiredKeys: const ['class_name'],
        );
        final val = FlutterGenElementFontsOutputs(
          className: $checkedConvert('class_name', (v) => v as String),
          packageParameterEnabled: $checkedConvert(
              'package_parameter_enabled', (v) => v as bool? ?? false),
        );
        return val;
      },
      fieldKeyMap: const {
        'className': 'class_name',
        'packageParameterEnabled': 'package_parameter_enabled'
      },
    );
