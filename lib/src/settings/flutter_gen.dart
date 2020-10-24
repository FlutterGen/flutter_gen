import 'dart:io';

import 'package:yaml/yaml.dart';

import '../generators/integrations/integration.dart';
import '../generators/integrations/svg_integration.dart';
import '../utils/cast.dart';
import 'config.dart';

class FlutterGen {
  FlutterGen._({
    outputDirectory,
    lineLength,
    integrations,
    assets,
    colors,
  })  : outputDirectory = outputDirectory ?? Config.defaultOutputDirectory,
        lineLength = lineLength ?? Config.defaultLineLength,
        integrations = integrations ?? FlutterGenIntegrations.empty(),
        assets = assets ?? FlutterGenAssets.empty(),
        colors = colors ?? FlutterGenColors.empty();

  FlutterGen.empty() : this._();

  factory FlutterGen.fromYaml(YamlMap flutterGenMap) {
    if (flutterGenMap == null) {
      return FlutterGen.empty();
    }

    final output = safeCast<String>(flutterGenMap['output']);
    if (output != null && !FileSystemEntity.isDirectorySync(output)) {
      Directory(output).createSync(recursive: true);
    }

    final lineLength = safeCast<int>(flutterGenMap['lineLength']);

    FlutterGenIntegrations integrations;
    if (flutterGenMap.containsKey('integrations')) {
      integrations = FlutterGenIntegrations.fromYaml(
          safeCast<YamlMap>(flutterGenMap['integrations']));
    }

    FlutterGenAssets assets;
    if (flutterGenMap.containsKey('assets')) {
      assets =
          FlutterGenAssets.fromYaml(safeCast<YamlMap>(flutterGenMap['assets']));
    }

    FlutterGenColors colors;
    if (flutterGenMap.containsKey('colors')) {
      colors =
          FlutterGenColors.fromYaml(safeCast<YamlMap>(flutterGenMap['colors']));
    }
    return FlutterGen._(
      outputDirectory: output,
      lineLength: lineLength,
      integrations: integrations,
      assets: assets,
      colors: colors,
    );
  }

  final String outputDirectory;

  final int lineLength;

  final FlutterGenIntegrations integrations;

  final FlutterGenAssets assets;

  final FlutterGenColors colors;
}

class FlutterGenColors {
  FlutterGenColors._({inputs}) : inputs = inputs ?? YamlList();

  FlutterGenColors.empty() : this._();

  factory FlutterGenColors.fromYaml(YamlMap flutterGenMap) {
    if (flutterGenMap == null) {
      return FlutterGenColors.empty();
    }
    YamlList inputs;
    if (flutterGenMap != null) {
      inputs = safeCast<YamlList>(flutterGenMap['inputs']);
    }
    return FlutterGenColors._(inputs: inputs);
  }

  final YamlList inputs;
}

class FlutterGenAssets {
  static const dotDelimiterStyle = 'dot-delimiter';
  static const snakeCaseStyle = 'snake-case';
  static const camelCaseStyle = 'camel-case';

  FlutterGenAssets._({String style}) : style = style ?? dotDelimiterStyle;

  FlutterGenAssets.empty() : this._();

  factory FlutterGenAssets.fromYaml(YamlMap flutterGenMap) {
    if (flutterGenMap == null) {
      return FlutterGenAssets.empty();
    }
    String style;
    if (flutterGenMap != null) {
      style = safeCast<String>(flutterGenMap['style']);
    }
    return FlutterGenAssets._(style: style);
  }

  final String style;

  bool get isDefaultStyle => isDotDelimiterStyle;

  bool get isDotDelimiterStyle => style == dotDelimiterStyle;

  bool get isSnakeCaseStyle => style == snakeCaseStyle;

  bool get isCamelCaseStyle => style == camelCaseStyle;
}

class FlutterGenIntegrations {
  FlutterGenIntegrations._({List<Integration> integrations})
      : integrations = integrations ?? List.empty();

  FlutterGenIntegrations.empty() : this._();

  factory FlutterGenIntegrations.fromYaml(YamlMap flutterGenMap) {
    if (flutterGenMap == null) {
      return FlutterGenIntegrations.empty();
    }
    final integrations = _parseIntegration(flutterGenMap);
    return FlutterGenIntegrations._(integrations: integrations);
  }

  final List<Integration> integrations;
}

// TODO: Refactor to accept YamlNode
List<Integration> _parseIntegration(YamlMap flutterGenMap) {
  return [
    if (safeCast<bool>(flutterGenMap['flutter_svg']) == true) SvgIntegration()
  ];
}
