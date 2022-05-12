import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen_core/flutter_generator.dart';
import 'package:flutter_gen_core/settings/config.dart';
import 'package:glob/glob.dart';

class FlutterGenBuilder extends Builder {
  final FlutterGenerator generator = FlutterGenerator(File('pubspec.yaml'));
  _FlutterGenBuilderState? _currentState;

  @override
  Future<void> build(BuildStep buildStep) async {
    var config = await generator.getConfig();

    if (config == null) return;

    var state = await _createState(config, buildStep);

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
    final HashMap<String, Digest> colors = HashMap();
    final HashSet<String> assets = HashSet();

    if (pubspec.flutterGen.colors.enabled) {
      for (var colorInput in pubspec.flutterGen.colors.inputs) {
        if (colorInput.isEmpty) continue;
        await for (var assetId in buildStep.findAssets(Glob(colorInput))) {
          var digest = await buildStep.digest(assetId);
          colors[assetId.path] = digest;
        }
      }
    }

    if (pubspec.flutterGen.fonts.enabled) {
      for (var fontInput in pubspec.flutter.fonts) {
        for (var fontAsset in fontInput.fonts) {
          if (fontAsset.asset.isEmpty) continue;
          await for (var assetId
              in buildStep.findAssets(Glob(fontAsset.asset))) {
            assets.add(assetId.path);
          }
        }
      }
    }

    if (pubspec.flutterGen.assets.enabled) {
      for (var assetInput in pubspec.flutter.assets) {
        if (assetInput.isEmpty) continue;
        if (assetInput.endsWith("/")) assetInput += "*";
        await for (var assetId in buildStep.findAssets(Glob(assetInput))) {
          assets.add(assetId.path);
        }
      }
    }

    final pubspecAsset =
        await buildStep.findAssets(Glob(config.pubspecFile.path)).single;

    final pubspecDigest = await buildStep.digest(pubspecAsset);

    return _FlutterGenBuilderState(pubspecDigest, colors, assets);
  }
}

class _FlutterGenBuilderState {
  final Digest pubspecDigest;
  final HashMap<String, Digest> colors;
  final HashSet<String> assets;

  _FlutterGenBuilderState(this.pubspecDigest, this.colors, this.assets);

  bool equals(_FlutterGenBuilderState state) {
    return pubspecDigest == state.pubspecDigest &&
        const MapEquality().equals(colors, state.colors) &&
        const SetEquality().equals(assets, state.assets);
  }
}
