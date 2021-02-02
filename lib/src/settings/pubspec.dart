import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';

part 'pubspec.g.dart';

final String _defaultOutput = 'lib${separator}gen$separator';
const int _defaultLineLength = 80;

@JsonSerializable()
class PubSpec {
  PubSpec({this.flutterGen, this.flutter});

  @JsonKey(name: 'flutter_gen')
  final FlutterGen flutterGen;

  @JsonKey(name: 'flutter')
  final Flutter flutter;

  factory PubSpec.fromJson(Map json) => _$PubSpecFromJson(json);
}

@JsonSerializable()
class Flutter {
  Flutter({this.assets, this.fonts}) {
    if (assets.isEmpty) {
      throw ArgumentError.value(assets, 'assets', 'Cannot be empty');
    }
    if (fonts.isEmpty) {
      throw ArgumentError.value(assets, 'fonts', 'Cannot be empty');
    }
  }

  @JsonKey(name: 'assets')
  final List<String> assets;

  @JsonKey(name: 'fonts')
  final List<FlutterFonts> fonts;

  factory Flutter.fromJson(Map json) => _$FlutterFromJson(json);
}

@JsonSerializable()
class FlutterFonts {
  FlutterFonts({this.family}) {
    if (family.isEmpty) {
      throw ArgumentError.value(family, 'family', 'Cannot be empty');
    }
  }

  @JsonKey(name: 'family', required: true)
  final String family;

  factory FlutterFonts.fromJson(Map json) => _$FlutterFontsFromJson(json);
}

@JsonSerializable()
class FlutterGen {
  FlutterGen({output, lineLength, this.deprecatedLineLength, this.assets})
      : output = output ?? _defaultOutput,
        lineLength = lineLength ?? deprecatedLineLength ?? _defaultLineLength {
    if (!FileSystemEntity.isDirectorySync(this.output)) {
      throw ArgumentError.value(output, 'output', 'Must be a valid directory.');
    }
    if (deprecatedLineLength != null) {
      print('Warning: key lineLength is deprecated, use line_length instead.');
    }
  }

  @JsonKey(name: 'output')
  final String output;

  @JsonKey(name: 'line_length', defaultValue: _defaultLineLength)
  final int lineLength;

  @deprecated
  @JsonKey(name: 'lineLength')
  final int deprecatedLineLength;

  @JsonKey(name: 'assets')
  final FlutterGenAssets assets;

  factory FlutterGen.fromJson(Map json) => _$FlutterGenFromJson(json);
}

@JsonSerializable()
class FlutterGenColors {
  FlutterGenColors({this.inputs}) {
    if (inputs.isEmpty) {
      throw ArgumentError.value(inputs, 'inputs', 'Cannot be empty.');
    }
  }

  @JsonKey(name: 'inputs', required: true)
  final List<String> inputs;

  bool get hasInputs => inputs != null && inputs.isNotEmpty;

  factory FlutterGenColors.fromJson(Map json) =>
      _$FlutterGenColorsFromJson(json);
}

@JsonSerializable()
class FlutterGenAssets {
  static const String dotDelimiterStyle = 'dot-delimiter';
  static const String snakeCaseStyle = 'snake-case';
  static const String camelCaseStyle = 'camel-case';

  FlutterGenAssets({this.style}) {
    if (style != dotDelimiterStyle ||
        style != snakeCaseStyle ||
        style != camelCaseStyle) {
      throw ArgumentError.value(style, 'style', 'Invalid style.');
    }
  }

  @JsonKey(name: 'style', defaultValue: dotDelimiterStyle)
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

  @JsonKey(name: 'flutter_svg', defaultValue: false)
  final bool flutterSvg;

  @JsonKey(name: 'flare_flutter', defaultValue: false)
  final bool flareFlutter;

  factory FlutterGenIntegrations.fromJson(Map json) =>
      _$FlutterGenIntegrationsFromJson(json);
}
