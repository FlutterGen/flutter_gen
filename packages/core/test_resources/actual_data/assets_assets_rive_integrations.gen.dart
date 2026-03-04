// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as _rive;

class $AssetsRiveGen {
  const $AssetsRiveGen();

  /// File path: assets/rive/vehicles.riv
  RiveGenImage get vehicles => const RiveGenImage('assets/rive/vehicles.riv');

  /// List of all assets
  List<RiveGenImage> get values => [vehicles];
}

class Assets {
  const Assets._();

  static const $AssetsRiveGen rive = $AssetsRiveGen();
}

class RiveGenImage {
  const RiveGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _rive.FileLoader riveFileLoader({_rive.Factory? factory}) {
    return _rive.FileLoader.fromAsset(
      _assetName,
      riveFactory: factory ?? _rive.Factory.rive,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
