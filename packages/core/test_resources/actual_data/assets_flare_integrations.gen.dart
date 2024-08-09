/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flare_flutter/flare_actor.dart' as _flare_actor;
import 'package:flare_flutter/flare_controller.dart' as _flare_controller;
import 'package:flutter/widgets.dart';

class $AssetsFlareGen {
  const $AssetsFlareGen();

  /// File path: assets/flare/Penguin.flr
  FlareGenImage get penguin => const FlareGenImage('assets/flare/Penguin.flr');

  /// List of all assets
  List<FlareGenImage> get values => [penguin];
}

class Assets {
  Assets._();

  static const $AssetsFlareGen flare = $AssetsFlareGen();
}

class FlareGenImage {
  const FlareGenImage(
    this._assetName, {
    this.flavors = const {},
  });

  final String _assetName;
  final Set<String> flavors;

  _flare_actor.FlareActor flare({
    String? boundsNode,
    String? animation,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool isPaused = false,
    bool snapToEnd = false,
    _flare_controller.FlareController? controller,
    _flare_actor.FlareCompletedCallback? callback,
    Color? color,
    bool shouldClip = true,
    bool sizeFromArtboard = false,
    String? artboard,
    bool antialias = true,
  }) {
    return _flare_actor.FlareActor(
      _assetName,
      boundsNode: boundsNode,
      animation: animation,
      fit: fit,
      alignment: alignment,
      isPaused: isPaused,
      snapToEnd: snapToEnd,
      controller: controller,
      callback: callback,
      color: color,
      shouldClip: shouldClip,
      sizeFromArtboard: sizeFromArtboard,
      artboard: artboard,
      antialias: antialias,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
