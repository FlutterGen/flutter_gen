import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'pubspec.g.dart';

@JsonSerializable()
class PubSpec {
  PubSpec({this.flutterGen, this.flutter});

  @JsonKey(name: 'flutter_gen', required: true)
  final FlutterGen flutterGen;

  @JsonKey(name: 'flutter', required: true)
  final Flutter flutter;

  factory PubSpec.fromJson(Map json) => _$PubSpecFromJson(json);
}

@JsonSerializable()
class Flutter {
  Flutter({this.assets, this.fonts});

  @JsonKey(name: 'assets', required: true)
  final List<String> assets;

  @JsonKey(name: 'fonts', required: true)
  final List<FlutterFonts> fonts;

  factory Flutter.fromJson(Map json) => _$FlutterFromJson(json);
}

@JsonSerializable()
class FlutterFonts {
  FlutterFonts({this.family});

  @JsonKey(name: 'family', required: true)
  final String family;

  factory FlutterFonts.fromJson(Map json) => _$FlutterFontsFromJson(json);
}

@JsonSerializable()
class FlutterGen {
  FlutterGen({
    this.output,
    this.lineLength,
    this.deprecatedLineLength,
    this.assets,
    this.integrations,
    this.colors,
  }) {
    if (!FileSystemEntity.isDirectorySync(output)) {
      throw ArgumentError.value(output, 'output');
    }
    if (deprecatedLineLength != null) {
      print('Warning: key lineLength is deprecated, use line_length instead.');
    }
  }

  @JsonKey(name: 'output', required: true)
  final String output;

  @JsonKey(name: 'line_length', required: true)
  final int lineLength;

  @deprecated
  @JsonKey(name: 'lineLength', required: true)
  final int deprecatedLineLength;

  @JsonKey(name: 'assets', required: true)
  final FlutterGenAssets assets;

  @JsonKey(name: 'integrations', required: true)
  final FlutterGenIntegrations integrations;

  @JsonKey(name: 'colors', required: true)
  final FlutterGenColors colors;

  factory FlutterGen.fromJson(Map json) => _$FlutterGenFromJson(json);
}

@JsonSerializable()
class FlutterGenColors {
  FlutterGenColors({this.inputs});

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

  FlutterGenAssets({this.style}) {
    if (style != dotDelimiterStyle &&
        style != snakeCaseStyle &&
        style != camelCaseStyle) {
      throw ArgumentError.value(style, 'style');
    }
  }

  @JsonKey(name: 'style', required: true)
  final String style;

  bool get isDotDelimiterStyle => style == dotDelimiterStyle;

  bool get isSnakeCaseStyle => style == snakeCaseStyle;

  bool get isCamelCaseStyle => style == camelCaseStyle;

  factory FlutterGenAssets.fromJson(Map json) =>
      _$FlutterGenAssetsFromJson(json);
}

@JsonSerializable()
class FlutterGenIntegrations {
  FlutterGenIntegrations({this.flutterSvg, this.flareFlutter});

  @JsonKey(name: 'flutter_svg', required: true)
  final bool flutterSvg;

  @JsonKey(name: 'flare_flutter', required: true)
  final bool flareFlutter;

  factory FlutterGenIntegrations.fromJson(Map json) =>
      _$FlutterGenIntegrationsFromJson(json);
}
