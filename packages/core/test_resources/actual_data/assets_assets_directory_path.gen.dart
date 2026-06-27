// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter_gen_interface/flutter_gen_interface.dart';
export 'package:flutter_gen_interface/flutter_gen_interface.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/chip3
  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();

  /// Directory path: assets/images
  String get path => 'assets/images';
}

class $AssetsUnknownGen {
  const $AssetsUnknownGen();

  /// File path: assets/unknown/unknown_mime_type.bk
  String get unknownMimeType => 'assets/unknown/unknown_mime_type.bk';

  /// Directory path: assets/unknown
  String get path => 'assets/unknown';

  /// List of all assets
  List<String> get values => [unknownMimeType];
}

class $AssetsImagesChip3Gen {
  const $AssetsImagesChip3Gen();

  /// File path: assets/images/chip3/chip3.jpg
  AssetGenImage get chip3 =>
      const AssetGenImage('assets/images/chip3/chip3.jpg');

  /// Directory path: assets/images/chip3
  String get path => 'assets/images/chip3';

  /// List of all assets
  List<AssetGenImage> get values => [chip3];
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/dart@test.svg
  SvgGenImage get dartTest =>
      const SvgGenImage('assets/images/icons/dart@test.svg');

  /// File path: assets/images/icons/fuchsia.svg
  SvgGenImage get fuchsia =>
      const SvgGenImage('assets/images/icons/fuchsia.svg');

  /// Directory path: assets/images/icons
  String get path => 'assets/images/icons';

  /// List of all assets
  List<SvgGenImage> get values => [dartTest, fuchsia];
}

abstract final class Assets {
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsUnknownGen unknown = $AssetsUnknownGen();
}
