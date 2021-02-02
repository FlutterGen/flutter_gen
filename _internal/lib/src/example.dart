import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'example.g.dart';

@JsonSerializable()
class PubSpec {
  PubSpec({this.flutterGen, this.flutter});

  @JsonKey(name: 'flutter_gen', required: true)
  final FlutterGen flutterGen;

  @JsonKey(name: 'flutter')
  final Flutter flutter;

  factory PubSpec.fromJson(Map json) => _$PubSpecFromJson(json);

  Map<String, dynamic> toJson() => _$PubSpecToJson(this);
}

@JsonSerializable()
class Flutter {
  Flutter({this.assets, this.fonts}) {
    if (assets.isEmpty) {
      throw ArgumentError.value(assets, 'assets', 'Cannot be empty');
    }
  }

  @JsonKey(name: 'assets')
  final List<String> assets;

  @JsonKey(name: 'fonts')
  final List<FlutterFonts> fonts;

  factory Flutter.fromJson(Map json) => _$FlutterFromJson(json);

  Map<String, dynamic> toJson() => _$FlutterToJson(this);
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

  Map<String, dynamic> toJson() => _$FlutterFontsToJson(this);
}

@JsonSerializable()
class FlutterGen {
  FlutterGen({output, this.lineLength, this.assets})
      : output = output ?? Config.defaultOutput {
    if (!FileSystemEntity.isDirectorySync(output)) {
      throw ArgumentError.value(output, 'output', 'Must be a valid directory.');
    }
  }

  @JsonKey(name: 'output')
  final String output;

  @JsonKey(name: 'lineLength', defaultValue: 80)
  final int lineLength;

  @JsonKey(name: 'assets')
  final FlutterGenAssets assets;

  factory FlutterGen.fromJson(Map json) => _$FlutterGenFromJson(json);

  Map<String, dynamic> toJson() => _$FlutterGenToJson(this);
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

  Map<String, dynamic> toJson() => _$FlutterGenColorsToJson(this);
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

  Map<String, dynamic> toJson() => _$FlutterGenAssetsToJson(this);
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

  Map<String, dynamic> toJson() => _$FlutterGenIntegrationsToJson(this);
}
