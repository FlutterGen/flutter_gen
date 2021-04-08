import 'package:json_annotation/json_annotation.dart';

part 'pubspec.g.dart';

/// Edit this file, then run `make generate-config-model`

const invalidStringValue = 'FLUTTER_GEN_INVALID';

@JsonSerializable()
class Pubspec {
  Pubspec({
    required this.packageName,
    required this.flutterGen,
    required this.flutter,
  });

  @JsonKey(name: 'name', required: true)
  final String packageName;

  @JsonKey(name: 'flutter_gen', required: true)
  final FlutterGen flutterGen;

  @JsonKey(name: 'flutter', required: true)
  final Flutter flutter;

  factory Pubspec.fromJson(Map json) => _$PubspecFromJson(json);
}

@JsonSerializable()
class Flutter {
  Flutter({required this.assets, required this.fonts});

  @JsonKey(name: 'assets', required: true)
  final List<String> assets;

  @JsonKey(name: 'fonts', required: true)
  final List<FlutterFonts> fonts;

  factory Flutter.fromJson(Map json) => _$FlutterFromJson(json);
}

@JsonSerializable()
class FlutterFonts {
  FlutterFonts({required this.family});

  @JsonKey(name: 'family', required: true)
  final String family;

  factory FlutterFonts.fromJson(Map json) => _$FlutterFontsFromJson(json);
}

@JsonSerializable()
class FlutterGen {
  FlutterGen({
    required this.output,
    required this.lineLength1,
    required this.lineLength0,
    required this.nullSafety,
    required this.assets,
    required this.fonts,
    required this.integrations,
    required this.colors,
  }) {
    // ignore: deprecated_member_use_from_same_package
    if (lineLength1 <= 0 && lineLength0 <= 0) {
      throw ArgumentError.value(
        // ignore: deprecated_member_use_from_same_package
        lineLength1 <= 0 ? lineLength1 : lineLength0,
        lineLength1 <= 0 ? 'line_length' : 'lineLength',
      );
    }
    // ignore: deprecated_member_use_from_same_package
    if (lineLength0 > 0) {
      print('Warning: key lineLength is deprecated, use line_length instead.');
    }
  }

  @JsonKey(name: 'output', required: true)
  final String output;

  @JsonKey(name: 'line_length', required: true)
  final int lineLength1;

  @deprecated
  @JsonKey(name: 'lineLength', required: true)
  final int lineLength0;

  @JsonKey(name: 'null_safety', required: true)
  final bool nullSafety;

  @JsonKey(name: 'assets', required: true)
  final FlutterGenAssets assets;

  @JsonKey(name: 'fonts', required: true)
  final FlutterGenFonts fonts;

  @JsonKey(name: 'integrations', required: true)
  final FlutterGenIntegrations integrations;

  @JsonKey(name: 'colors', required: true)
  final FlutterGenColors colors;

  // Backwards compatible
  // ignore: deprecated_member_use_from_same_package
  int get lineLength => lineLength0 > 0 ? lineLength0 : lineLength1;

  factory FlutterGen.fromJson(Map json) => _$FlutterGenFromJson(json);
}

@JsonSerializable()
class FlutterGenColors {
  FlutterGenColors({required this.enabled, required this.inputs});

  @JsonKey(name: 'enabled', required: true)
  final bool enabled;

  @JsonKey(name: 'inputs', required: true)
  final List<String> inputs;

  factory FlutterGenColors.fromJson(Map json) =>
      _$FlutterGenColorsFromJson(json);
}

@JsonSerializable()
class FlutterGenAssets {
  static const String dotDelimiterStyle = 'dot-delimiter';
  static const String snakeCaseStyle = 'snake-case';
  static const String camelCaseStyle = 'camel-case';

  FlutterGenAssets({
    required this.enabled,
    required this.packageParameterEnabled,
    required this.style,
  }) {
    if (style != dotDelimiterStyle &&
        style != snakeCaseStyle &&
        style != camelCaseStyle) {
      throw ArgumentError.value(style, 'style');
    }
  }

  @JsonKey(name: 'enabled', required: true)
  final bool enabled;

  @JsonKey(name: 'package_parameter_enabled', required: true)
  final bool packageParameterEnabled;

  @JsonKey(name: 'style', required: true)
  final String style;

  bool get isDotDelimiterStyle => style == dotDelimiterStyle;

  bool get isSnakeCaseStyle => style == snakeCaseStyle;

  bool get isCamelCaseStyle => style == camelCaseStyle;

  factory FlutterGenAssets.fromJson(Map json) =>
      _$FlutterGenAssetsFromJson(json);
}

@JsonSerializable()
class FlutterGenFonts {
  FlutterGenFonts({required this.enabled});

  @JsonKey(name: 'enabled', required: true)
  final bool enabled;

  factory FlutterGenFonts.fromJson(Map json) => _$FlutterGenFontsFromJson(json);
}

@JsonSerializable()
class FlutterGenIntegrations {
  FlutterGenIntegrations(
      {required this.flutterSvg, required this.flareFlutter});

  @JsonKey(name: 'flutter_svg', required: true)
  final bool flutterSvg;

  @JsonKey(name: 'flare_flutter', required: true)
  final bool flareFlutter;

  factory FlutterGenIntegrations.fromJson(Map json) =>
      _$FlutterGenIntegrationsFromJson(json);
}
