import 'dart:collection';
import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:flutter_gen_core/settings/flavored_asset.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

Builder build(BuilderOptions options) => FlutterGenBuilder();

class FlutterGenBuilder extends Builder {
  static AssetId _output(BuildStep buildStep, String path) {
    return AssetId(
      buildStep.inputId.package,
      path,
    );
  }

  final generator = FlutterGenerator(
    File('pubspec.yaml'),
    buildFile: File('build.yaml'),
  );

  late final _config = loadPubspecConfigOrNull(
    generator.pubspecFile,
    buildFile: generator.buildFile,
  );
  _FlutterGenBuilderState? _currentState;

  @override
  Future<void> build(BuildStep buildStep) async {
    if (_config == null) {
      return;
    }
    final state = await _createState(_config!, buildStep);
    if (state.shouldSkipGenerate(_currentState)) {
      return;
    }
    _currentState = state;

    await generator.build(
      config: _config,
      writer: (contents, path) {
        buildStep.writeAsString(_output(buildStep, path), contents);
      },
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    if (_config == null) {
      return {};
    }
    final output = _config!.pubspec.flutterGen.output;
    return {
      r'$package$': [
        for (final name in [
          generator.assetsName,
          generator.colorsName,
          generator.fontsName,
        ])
          join(output, name),
      ],
    };
  }

  Future<_FlutterGenBuilderState> _createState(
    Config config,
    BuildStep buildStep,
  ) async {
    final pubspec = config.pubspec;

    final HashSet<FlavoredAsset> assets = HashSet();
    if (pubspec.flutterGen.assets.enabled) {
      for (final asset in pubspec.flutter.assets) {
        final FlavoredAsset flavored;
        String assetInput;
        if (asset is YamlMap) {
          flavored = FlavoredAsset(
            path: asset['path'],
            flavors:
                (asset['flavors'] as YamlList?)?.toSet().cast() ?? <String>{},
          );
          assetInput = asset['path'];
        } else {
          flavored = FlavoredAsset(path: asset as String);
          assetInput = asset;
        }
        if (assetInput.isEmpty) {
          continue;
        }
        if (assetInput.endsWith('/')) {
          assetInput += '*';
        }
        await for (final assetId in buildStep.findAssets(Glob(assetInput))) {
          assets.add(flavored.copyWith(path: assetId.path));
        }
      }
    }

    final HashMap<String, Digest> colors = HashMap();
    if (pubspec.flutterGen.colors.enabled) {
      for (final colorInput in pubspec.flutterGen.colors.inputs) {
        if (colorInput.isEmpty) {
          continue;
        }
        await for (final assetId in buildStep.findAssets(Glob(colorInput))) {
          final digest = await buildStep.digest(assetId);
          colors[assetId.path] = digest;
        }
      }
    }

    final pubspecAsset =
        await buildStep.findAssets(Glob(config.pubspecFile.path)).single;

    final pubspecDigest = await buildStep.digest(pubspecAsset);

    return _FlutterGenBuilderState(
      pubspecDigest: pubspecDigest,
      assets: assets,
      colors: colors,
    );
  }
}

class _FlutterGenBuilderState {
  const _FlutterGenBuilderState({
    required this.pubspecDigest,
    required this.assets,
    required this.colors,
  });

  final Digest pubspecDigest;
  final HashSet<FlavoredAsset> assets;
  final HashMap<String, Digest> colors;

  bool shouldSkipGenerate(_FlutterGenBuilderState? previous) {
    if (previous == null) {
      return false;
    }
    return pubspecDigest == previous.pubspecDigest &&
        const SetEquality().equals(assets, previous.assets) &&
        const MapEquality().equals(colors, previous.colors);
  }
}
