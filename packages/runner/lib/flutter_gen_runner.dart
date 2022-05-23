import 'dart:collection';
import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';

import 'package:glob/glob.dart';

Builder build(BuilderOptions options) => FlutterGenBuilder();

class FlutterGenBuilder extends Builder {
  final FlutterGenerator generator = FlutterGenerator(File('pubspec.yaml'));
  _FlutterGenBuilderState? _currentState;

  @override
  Future<void> build(BuildStep buildStep) async {
    final config = await generator.getConfig();
    if (config == null) return;

    final state = await _createState(config, buildStep);
    if (_currentState != null && _currentState!.equals(state)) return;
    _currentState = state;

    await generator.build(config: config);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        "\$package\$": ['.gen.dart']
      };

  Future<_FlutterGenBuilderState> _createState(
      Config config, BuildStep buildStep) async {
    final pubspec = config.pubspec;

    final HashSet<String> assets = HashSet();
    if (pubspec.flutterGen.assets.enabled) {
      for (var assetInput in pubspec.flutter.assets) {
        if (assetInput.isEmpty) continue;
        if (assetInput.endsWith("/")) assetInput += "*";
        await for (var assetId in buildStep.findAssets(Glob(assetInput))) {
          assets.add(assetId.path);
        }
      }
    }

    final HashMap<String, Digest> colors = HashMap();
    if (pubspec.flutterGen.colors.enabled) {
      for (var colorInput in pubspec.flutterGen.colors.inputs) {
        if (colorInput.isEmpty) continue;
        await for (var assetId in buildStep.findAssets(Glob(colorInput))) {
          final digest = await buildStep.digest(assetId);
          colors[assetId.path] = digest;
        }
      }
    }

    final pubspecAsset =
        await buildStep.findAssets(Glob(config.pubspecFile.path)).single;

    final pubspecDigest = await buildStep.digest(pubspecAsset);

    return _FlutterGenBuilderState(pubspecDigest, assets, colors);
  }
}

class _FlutterGenBuilderState {
  final Digest pubspecDigest;
  final HashSet<String> assets;
  final HashMap<String, Digest> colors;

  _FlutterGenBuilderState(this.pubspecDigest, this.assets, this.colors);

  bool equals(_FlutterGenBuilderState state) {
    return pubspecDigest == state.pubspecDigest &&
        const SetEquality().equals(assets, state.assets) &&
        const MapEquality().equals(colors, state.colors);
  }
}
